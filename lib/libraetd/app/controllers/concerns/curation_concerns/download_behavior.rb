# Overrides Hydra::Controller::DownloadBehavior to accommodate the fact that PCDM Objects#files uses direct containment instead of basic containment
module CurationConcerns
  module DownloadBehavior
    extend ActiveSupport::Concern
    include Hydra::Controller::DownloadBehavior

    include StatisticsHelper

    module ClassMethods
      def default_content_path
        :original_file
      end
    end

    # Render the 404 page if the file doesn't exist.
    # Otherwise renders the file.
    def show
      if is_allowed_to_see_file(params['id'])
      case file
        when ActiveFedora::File
        # For original files that are stored in fedora
        super

        # save file download statistics
        record_file_download_event( params['id'] )

      when String
        # For derivatives stored on the local file system
        response.headers['Accept-Ranges'] = 'bytes'
        response.headers['Content-Length'] = File.size(file).to_s
        send_file file, derivative_download_options

        # we dont save file download statistics from here, they are thumbnails only
      else
        render_404
      end
      else
        render_404
      end
    end

    protected

    def content_options
      { disposition: "attachment; filename=#{file_name}", type: file.mime_type, filename: file_name }
    end

    def is_allowed_to_see_file(id)

      # TODO: roll-up identical functionality from EmbargoHelper:allow_file_access

      file_set = ::FileSet.find(id)
      if file_set.nil?
         puts "==> fileset is undefined; view access is DENIED"
         return false
      end

      works = file_set.in_works()
      if works.nil? || works.empty?
         puts "==> fileset is unassociated with any work; view access is DENIED"
         return false
      end

      work = works[0]
      set_debugging_override()
      # can see the file according to these rules:
      # - if the current_user is the one who owns the work
      # - if the work is not draft and...
      # - if the work is publicly available
      # - if the embargo period is over
      # - if the work is under UVA embargo and the user is on grounds
      if current_user.nil? == false && work.is_mine?( current_user.email )
         puts "==> owning work is user owned; view access is GRANTED"
         return true
      elsif work.is_draft? == true
        puts "==> owning work is private; view access is DENIED"
        return false
      elsif view_context.is_under_embargo(work) == false
        puts "==> owning work is public; view access is GRANTED"
        # it's not embargoed so we can see it
        return true
      elsif view_context.is_engineering_embargo(work) == true
        puts "==> owning work is engineering embargo; view access is DENIED"
        # can never see engineering embargoed files
        return false
      else
        # must be UVA embargo, so only see files on grounds.
        on_grounds = view_context.is_on_grounds()
        puts "==> owning work is under embargo and we are off grounds; view access is DENIED" if on_grounds == false
        puts "==> owning work is under embargo and we are on grounds; view access is GRANTED" if on_grounds == true
        return on_grounds
      end
    end

      # Override this method if you want to change the options sent when downloading
      # a derivative file
      def derivative_download_options
        { type: mime_type_for(file), disposition: 'inline' }
      end

    # Customize the :read ability in your Ability class, or override this method.
    # Hydra::Ability#download_permissions can't be used in this case because it assumes
    # that files are in a LDP basic container, and thus, included in the asset's uri.
    def authorize_download!
      authorize! :read, params[asset_param_key]
    end

      # Overrides Hydra::Controller::DownloadBehavior#load_file, which is hard-coded to assume files are in BasicContainer.
      # Override this method to change which file is shown.
      # Loads the file specified by the HTTP parameter `:file`.
      # If this object does not have a file by that name, return the default file
      # as returned by {#default_file}
      # @return [ActiveFedora::File, String, NilClass] Returns the file from the repository or a path to a file on the local file system, if it exists.
      def load_file
        file_reference = params[:file]
        return default_file unless file_reference

        file_path = CurationConcerns::DerivativePath.derivative_path_for_reference(params[asset_param_key], file_reference)
        File.exist?(file_path) ? file_path : nil
      end

      def default_file
        default_file_reference = if asset.class.respond_to?(:default_file_path)
                                   asset.class.default_file_path
                                 else
                                   DownloadsController.default_content_path
                                 end
        association = dereference_file(default_file_reference)
        association.reader if association
      end

    private

      def mime_type_for(file)
        MIME::Types.type_for(File.extname(file)).first.content_type
      end

      def dereference_file(file_reference)
        return false if file_reference.nil?
        association = asset.association(file_reference.to_sym)
        association if association && association.is_a?(ActiveFedora::Associations::SingularAssociation)
      end
  end
end
