# Overrides Hydra::Controller::DownloadBehavior to accommodate the fact that PCDM Objects#files uses direct containment instead of basic containment
module CurationConcerns
  module DownloadBehavior
    extend ActiveSupport::Concern
    include Hydra::Controller::DownloadBehavior

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
      when String
        # For derivatives stored on the local file system
        response.headers['Accept-Ranges'] = 'bytes'
        response.headers['Content-Length'] = File.size(file).to_s
        send_file file, derivative_download_options
      else
        render_404
      end
      else
          render_404
        end
    end

    protected

    def is_allowed_to_see_file(id)
      file_set = ::FileSet.find(id)
      return false if file_set.nil?
      works = file_set.in_works()
      return false if works.nil? || works.empty?
      work = works[0]
      set_debugging_override()
      # can see the file according to these rules:
      # - if the current_user is the one who owns the work
      # - if the work is not draft and...
      # - if the work is publicly available
      # - if the embargo period is over
      # - if the work is under UVA embargo and the user is on grounds
      if current_user.nil? == false && work.is_mine?( current_user.email )
         return true
      elsif work.is_draft? == true
        return false
      elsif view_context.is_under_embargo(work) == false
        # it's not embargoed so we can see it
        return true
      elsif view_context.is_engineering_embargo(work) == true
        # can never see engineering embargoed files
        return false
      else
        # must be UVA embargo, so only see files on grounds.
        return view_context.is_on_grounds()
      end
    end

      # Override this method if you want to change the options sent when downloading
      # a derivative file
      def derivative_download_options
        { type: mime_type_for(file), disposition: 'inline' }
      end

      # Customize the :download ability in your Ability class, or override this method
      def authorize_download!
        # authorize! :download, file # can't use this because Hydra::Ability#download_permissions assumes that files are in Basic Container (and thus include the asset's uri)
        authorize! :read, asset
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

        file_path = CurationConcerns::DerivativePath.derivative_path_for_reference(asset, file_reference)
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
