require_dependency 'libraetd/lib/serviceclient/auth_token_client'
require "csv"

class APIBaseController < ApplicationController

  include ServiceHelper

  # disable rails auth behavior and add our own
  #skip_before_action :require_auth
  skip_before_action :verify_authenticity_token
  before_action :validate_token

  # default query limits
  DEFAULT_LIMIT = 1000

  # handle exceptions in a special manner
  rescue_from Exception do |exception|
    puts "======> #{exception.class}"
    puts exception.backtrace.join("\n")
    render_standard_response( :internal_error, exception )
  end

  attr_accessor :api_user

  private

  def get_the_work( id = nil )
    id = params[:id] if id.nil?
    begin
      return GenericWork.find( id )
    rescue => ex
      puts "==> get_the_work exception: #{ex}"
    end
    return nil
  end

  def get_the_fileset( id = nil )
    id = params[:id] if id.nil?
    begin
      return FileSet.find( id )
    rescue => ex
      puts "==> get_the_fileset exception: #{ex}"
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

  def numeric( str, default )
    begin
      return default if str.blank?
      return str.to_i
    rescue => e
      return default
    end
  end

end
