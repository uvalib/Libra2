require 'securerandom'

class APIV1FilesetsController < APIBaseController

  include UploadCacheBehavior
  include UrlHelper

  before_action :validate_user, only: [ :add_fileset,
                                        :remove_fileset
                                      ]

  #
  # get all filesets
  #
  def all_filesets
    limit = numeric( params[:limit], DEFAULT_LIMIT )
    filesets = FileSet.all.limit( limit )
    if filesets.empty? == false
      render_fileset_response( :ok, fileset_transform( filesets ) )
    else
      render_fileset_response( :not_found )
    end

  end

  #
  # get the specified fileset
  #
  def get_fileset
    fileset = get_the_fileset
    if fileset.nil? == false
      render_fileset_response( :ok, fileset_transform( [ fileset ] ) )
    else
      render_fileset_response( :not_found )
    end
  end

  #
  # add a new file(set)
  #
  def add_fileset

    # grab the parameters
    work_id = params[:work]
    file_id = params[:file]
    label = params[:label]

    # validate them
    if work_id.blank? == false && file_id.blank? == false && label.blank? == false
       work = get_the_work( work_id )
       if work.nil? == false
         filename = APIV1FilesetsController.cache_contents( file_id )
         if filename.blank? == false
            fileset = ::FileSet.new
            fileset.title << label
            file_actor = ::CurationConcerns::Actors::FileSetActor.new( fileset, @api_user )
            file_actor.create_metadata( work )
            file_actor.create_content( File.open( filename ) )

            # audit the information
            audit_log( "File #{label} for work id #{work_id} (#{work.identifier}) added by #{User.cid_from_email( @api_user.email)}" )

            render_standard_response( :ok )
         else
            render_standard_response( :not_found, 'File not found' )
         end
       else
          render_standard_response( :not_found, 'Work not found' )
       end
    else
      render_standard_response( :unauthorized, 'Missing work identifier or file identifier or file label' )
    end

  end

  #
  # remove the specified fileset
  #
  def remove_fileset

    fileset = get_the_fileset
    if fileset.nil? == false
      works = fileset.in_works
      work_id = works.empty? ? 'unknown' : works[0].id
      work_identifier = works.empty? ? 'unknown' : works[0].identifier

      # audit the information
      audit_log( "File #{fileset.title[0]} for work id #{work_id} (#{work_identifier}) deleted by #{User.cid_from_email( @api_user.email)}" )

      file_actor = ::CurationConcerns::Actors::FileSetActor.new( fileset, @api_user )
      file_actor.destroy
      render_standard_response( :ok )
    else
      render_standard_response( :not_found, 'Fileset not available' )
    end

  end

  private

  def render_fileset_response( status, filesets = nil )
    render json: API::FilesetListResponse.new( status, filesets ), :status => status
  end

  def fileset_transform( filesets )
    return [] if filesets.empty?
    return filesets.map { | fs | API::Fileset.new.from_fileset( fs, "#{public_site_url}/api/v1" ) }
  end

end


