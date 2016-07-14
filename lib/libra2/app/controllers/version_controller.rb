class VersionController < ApplicationController

  skip_before_filter :require_auth

  # the response
  class VersionResponse

    attr_accessor :version

    def initialize( version )
      @version = version
    end
  end

  # # GET /version
  # # GET /version.json
  def index
    version = get_version( )
    response = VersionResponse.new( version )
    render json: response, :status => 200
  end

  private

  def get_version
    tag_pattern = "#{Rails.application.root}/buildtag.*"
    files = Dir.glob( tag_pattern )
    if files.length == 1
       return File.basename( files[ 0 ] ).gsub( /buildtag./, '' )
    end
    return( 'unknown' )
  end

end
