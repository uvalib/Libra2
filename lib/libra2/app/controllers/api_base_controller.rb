require_dependency 'libra2/lib/serviceclient/auth_token_client'

class APIBaseController < ApplicationController

  include ServiceHelper

  # disable rails auth behavior and add our own
  skip_before_filter :require_auth
  skip_before_filter :verify_authenticity_token
  before_action :validate_token

  attr_accessor :api_user

  private

  def get_the_work
    id = params[:id]
    begin
      return GenericWork.find( id )
    rescue => e
    end
    return nil
  end

  def get_the_fileset
    id = params[:id]
    begin
      return FileSet.find( id )
    rescue => e
    end
    return nil
  end

  def validate_token
    auth = params[:auth]
    if valid_auth?( auth )
      return
    end
    render_standard_response( :unauthorized, 'Missing or incorrect authentication token' )
  end

  def validate_user
    user = params[:user]
    if valid_user?( user )
      return
    end
    render_standard_response( :unauthorized, 'Missing or incorrect user parameter' )
  end

  def render_standard_response( status, message = nil )
    render json: API::BaseResponse.new( status, message ), :status => status
  end

  def valid_auth?( auth )
    status = ServiceClient::AuthTokenClient.instance.auth( 'api', 'access', auth )
    return ServiceClient::AuthTokenClient.instance.ok?( status )
  end

  def valid_user?( user )
    return false if user.blank?
    @api_user = User.find_by_email( "#{user}@virginia.edu" )
    return @api_user.nil? == false
  end

  def audit_log( message )
    logger.info "API: #{message}"
  end
end
