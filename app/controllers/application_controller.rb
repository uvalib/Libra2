class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller 
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds CurationConcerns behaviors to the application controller.
  include CurationConcerns::ApplicationControllerBehavior  
  # Adds Sufia behaviors into the application controller 
  include Sufia::Controller

  include CurationConcerns::ThemedLayoutController
  layout 'sufia-one-column'

  # Adds Libra2 authentication behavior
  include Libra2::AuthenticationBehavior

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied, :with => :render404
  rescue_from ActionController::RoutingError, :with => :render404
  rescue_from ActionView::MissingTemplate, :with => :render404

  #rescue_from Exception do |exception|
  #  puts "======> #{exception.class}"
  #  render404
  #end

  def render404
    render :file => "#{Rails.root}/public/404.html", :status => :not_found, :layout => false
  end

    def set_debugging_override()
      @today = Time.now
      @grounds_override = false
      if ENV['ALLOW_FAKE_NETBADGE'] == 'true'
        @grounds_override = params[:grounds] if params[:grounds].present?
        if params[:time].present?
          months = params[:time].to_i
          @today = Time.now + months.months
        end
      end
    end
end
