require 'securerandom'

class APIV1FilesetsController < APIBaseController

  #
  # create an uploaded class that determines where temp files are put
  #
  class FilesetAssetUploader < CarrierWave::Uploader::Base
    def store_dir
      return File.join( APIV1FilesetsController.upload_basedir, SecureRandom.hex( 5 ) )
    end
  end

  #
  # a cheat where I redefine a sufia class to piggyback on the existing active reford infrastructure
  #
  class UploadedFile < ActiveRecord::Base
    mount_uploader :file, FilesetAssetUploader

    before_destroy do |obj|
      obj.remove_file!
    end
  end

  # no token validation for the file upload
  skip_before_filter :validate_token, only: [:add_file, :add_file_options]

  before_action :validate_user, only: [ :add_fileset,
                                        :add_file,
                                        :remove_fileset
                                      ]

  #
  # cors preflight so we can upload from unknown domains
  #
  after_filter :set_access_control_headers, only: [:add_file_options]

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST'
    headers['Access-Control-Allow-Headers'] = 'Content-Type'
  end

  @default_limit = 100

  #
  # get all filesets
  #
  def all_filesets
    limit = params[:limit] || @default_limit
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
  # preflight/cors stuff
  #
  def add_file_options
    head(:ok) if request.request_method == 'OPTIONS'
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
         filename = locate_upload_file( file_id )
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

  #
  # add a new file
  #
  def add_file

    uploaded = UploadedFile.create params.permit( :file )
    filename = upload_name( uploaded.file.url )
    key = upload_key( uploaded.file.url )

    # audit the information
    audit_log( "File #{filename} uploaded by #{User.cid_from_email( @api_user.email)}" )

    render_upload_response( :ok, key )

  end

  private

  def locate_upload_file( id )
     dirname = File.join( APIV1FilesetsController.upload_basedir, id )
     if Dir.exist?( dirname )
        Dir.foreach( dirname ) do |item|
           next if item == '.' or item == '..'
           return File.join( dirname, item )
        end
     end

     return ''
  end

  def render_fileset_response( status, filesets = nil )
    render json: API::FilesetListResponse.new( status, filesets ), :status => status
  end

  def render_upload_response( status, id = nil )
    render json: API::UploadResponse.new( status, id ), :status => status
  end

  def upload_name( url )
    return File.basename( url )
  end

  def upload_key( url )
    return File.basename( File.dirname( url ) )
  end

  def self.upload_basedir
     return File.join( Rails.root, 'hostfs', 'uploads', 'tmp' )
  end

  def fileset_transform( filesets )
    return [] if filesets.empty?
    return filesets.map { | fs | API::Fileset.new.from_fileset( fs, "#{request.base_url}/api/v1" ) }
  end

end


