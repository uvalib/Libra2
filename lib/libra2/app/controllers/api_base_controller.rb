require_dependency 'libra2/lib/serviceclient/auth_token_client'

class APIBaseController < ApplicationController

  include ServiceHelper

  # disable rails auth behavior and add our own
  skip_before_filter :require_auth
  skip_before_filter :verify_authenticity_token
  before_action :validate_token

  private

  def get_the_work
    id = params[:id]
    begin
      return GenericWork.find( id )
    rescue => e
    end
    return nil
  end

  def validate_token
    auth = params[:auth]
    if valid_auth?( auth )
      return
    end
    status = :unauthorized
    render json: API::BaseResponse.new( status, 'Missing or incorrect authentication token' ), :status => status
  end

  def validate_user
    user = params[:user]
    if valid_user?( user )
      return
    end
    status = :unauthorized
    render json: API::BaseResponse.new( status, 'Missing user parameter' ), :status => status
  end

  def valid_auth?( auth )
    status = ServiceClient::AuthTokenClient.instance.auth( 'api', 'access', auth )
    return ServiceClient::AuthTokenClient.instance.ok?( status )
  end

  def valid_user?( user )
    return !user.blank?
  end

  def audit_log( message )
    logger.info "API: #{message}"
  end
end
