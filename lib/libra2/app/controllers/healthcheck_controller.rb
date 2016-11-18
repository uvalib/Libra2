require_dependency 'libra2/lib/serviceclient/deposit_auth_client'
require_dependency 'libra2/lib/serviceclient/deposit_reg_client'
require_dependency 'libra2/lib/serviceclient/entity_id_client'
require_dependency 'libra2/lib/serviceclient/orcid_access_client'
require_dependency 'libra2/lib/serviceclient/user_info_client'

class HealthcheckController < ApplicationController

  skip_before_filter :require_auth

  # the basic health status object
  class Health
    attr_accessor :healthy
    attr_accessor :message

    def initialize( status, message )
      @healthy = status
      @message = message
    end

  end

  # the response
  class HealthCheckResponse

    attr_accessor :depositauth
    attr_accessor :depositreg
    attr_accessor :entityid
    attr_accessor :orcidaccess
    attr_accessor :userinfo
    attr_accessor :mysql

    def is_healthy?
      depositauth.healthy && depositreg.healthy && entityid.healthy && orcidaccess.healthy && userinfo.healthy && mysql.healthy
    end
  end

  # # GET /healthcheck
  # # GET /healthcheck.json
  def index
    status = get_health_status( )
    response = make_response( status )
    render json: response, :status => response.is_healthy? ? 200 : 500
  end

  private

  def get_health_status
    status = {}

    # check the deposit auth endpoint
    rc = ServiceClient::DepositAuthClient.instance.healthcheck
    ok = ServiceClient::DepositAuthClient.instance.ok?( rc )
    status[ :depositauth ] = Health.new( ok, ok ? '' : "Endpoint returns #{rc}" )

    # check the deposit reg endpoint
    rc = ServiceClient::DepositRegClient.instance.healthcheck
    ok = ServiceClient::DepositRegClient.instance.ok?( rc )
    status[ :depositreg ] = Health.new( ok, ok ? '' : "Endpoint returns #{rc}" )

    # check the entity id endpoint
    rc = ServiceClient::EntityIdClient.instance.healthcheck
    ok = ServiceClient::EntityIdClient.instance.ok?( rc )
    status[ :entityid ] = Health.new( ok, ok ? '' : "Endpoint returns #{rc}" )

    # check the entity id endpoint
    rc = ServiceClient::OrcidAccessClient.instance.healthcheck
    ok = ServiceClient::OrcidAccessClient.instance.ok?( rc )
    status[ :orcidaccess ] = Health.new( ok, ok ? '' : "Endpoint returns #{rc}" )

    # check the user info endpoint
    rc = ServiceClient::UserInfoClient.instance.healthcheck
    ok = ServiceClient::UserInfoClient.instance.ok?( rc )
    status[ :userinfo ] = Health.new( ok, ok ? '' : "Endpoint returns #{rc}" )

    # check mysql
    connected = ActiveRecord::Base.connection_pool.with_connection { |con| con.active? }  rescue false
    status[ :mysql ] = Health.new( connected, connected ? '' : 'Database connection error' )

    return( status )
  end

  def make_response( health_status )
    r = HealthCheckResponse.new
    r.depositauth = health_status[ :depositauth ]
    r.depositreg = health_status[ :depositreg ]
    r.entityid = health_status[ :entityid ]
    r.orcidaccess = health_status[ :orcidaccess ]
    r.userinfo = health_status[ :userinfo ]
    r.mysql = health_status[ :mysql ]

    return( r )
  end

end
