class ApplicationController < ActionController::Base

  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include CurationConcerns::ThemedLayoutController
  with_themed_layout '1_column'

  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Hydra::Controller::ControllerBehavior

  # Adds CurationConcerns behaviors to the application controller.
  include CurationConcerns::ApplicationControllerBehavior
  # Adds Sufia behaviors into the application controller
  include Sufia::Controller

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied, :with => :render404
  rescue_from ActionController::RoutingError, :with => :render404
  rescue_from ActionView::MissingTemplate, :with => :render404

  rescue_from UncaughtThrowError do |exception|
    render401 if exception.tag == :warden

    # what do we do if this is not a :warden error?
  end

  #rescue_from Exception do |exception|
  #  puts "======> #{exception.class}"
  #  puts "======> #{exception.inspect}"
  #  render404
  #end

  def render404
    if user_signed_in?
      render :file => "#{Rails.root}/public/404.html", :status => :not_found, :layout => false
    else
      # This is the case where someone logs in with Shiboleth but does not have an account. This happens because of one of the following:
      # 1) They work here and are trying to see if Libra is active, but have no reason to upload,
      # 2) They are a student who has submitted to SIS, but has jumped the gun and went to Libra before their thesis had been created,
      # 3) They are a random UVA student who stumbled here but has no business here.
      render401
    end
  end

  def render401
    render :file => "#{Rails.root}/public/401.html", :status => :unauthorized, :layout => false
  end

  def render404public
    render :file => "#{Rails.root}/public/404-public.html", :status => :not_found, :layout => false
  end

    def set_debugging_override()
      @today = Time.now
      @grounds_override = false
      if ENV['ENABLE_TEST_FEATURES'].present?
        @grounds_override = params[:grounds] if params[:grounds].present?
        if params[:time].present?
          months = params[:time].to_i
          @today = Time.now + months.months
        end
      end
    end
end
