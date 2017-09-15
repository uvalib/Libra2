

class APIV1FilesController < APIBaseController

  include UploadCacheBehavior

  #
  # create an uploaded class that determines where temp files are put
  #
  class FilesetAssetUploader < CarrierWave::Uploader::Base
    def store_dir
      return APIV1FilesController.new_cache
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
  skip_before_action :validate_token, only: [:add_file, :add_file_options]
  before_action :validate_user, only: [ :add_file ]

  #
  # cors preflight so we can upload from unknown domains
  #
  after_filter :set_access_control_headers, only: [:add_file, :add_file_options]

  def set_access_control_headers
    #puts "===> set_access_control_headers"
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST'
    headers['Access-Control-Allow-Headers'] = 'Content-Type'
  end

  #
  # preflight/cors stuff
  #
  def add_file_options
    #puts "===> add_file_options"
    head(:ok) if request.request_method == 'OPTIONS'
  end

  #
  # add a new file
  #
  def add_file

    uploaded = UploadedFile.create params.permit( :file )
    filename = APIV1FilesController.cache_file_from_url( uploaded.file.url )
    key = APIV1FilesController.cache_key_from_url( uploaded.file.url )

    # audit the information
    audit_log( "File #{filename} uploaded by #{User.cid_from_email( @api_user.email)}" )

    render_upload_response( :ok, key )

  end

  private

  def render_upload_response( status, id = nil )
    render json: API::UploadResponse.new( status, id ), :status => status
  end

end


