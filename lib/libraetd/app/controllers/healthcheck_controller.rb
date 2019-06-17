class HealthcheckController < ApplicationController

  #skip_before_action :require_auth

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

    attr_accessor :repository
    attr_accessor :mysql

    def is_healthy?
      repository.healthy && mysql.healthy
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

    # check the repository
    ok = true
    msg = ''
    begin
      _ = GenericWork.first
    rescue RSolr::Error::Http, RSolr::Error::ConnectionRefused => ex
      ok = false
      msg = 'SOLR connection error'
      puts "SOLR connection error during healthcheck"
    rescue Ldp::HttpError => ex
      ok = false
      msg = 'Fedora connection error'
      puts "Fedora connection error during healthcheck"
    rescue => ex
      ok = false
      msg = "Error: #{ex.class}"
      puts "#{ex.class} error during healthcheck"
      puts "#{ex.backtrace.join("\n\t")}"
    end
    status[ :repository ] = Health.new( ok, msg )

    # check mysql
    connected = ActiveRecord::Base.connection_pool.with_connection { |con| con.active? }  rescue false
    status[ :mysql ] = Health.new( connected, connected ? '' : 'Database connection error' )

    return( status )
  end

  def make_response( health_status )
    r = HealthCheckResponse.new
    r.repository = health_status[ :repository ]
    r.mysql = health_status[ :mysql ]

    return( r )
  end

end
