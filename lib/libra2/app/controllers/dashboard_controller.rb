class DashboardController < ApplicationController
  include Sufia::DashboardControllerBehavior

  include Blacklight::Configurable

  include Blacklight::SearchHelper
  include Blacklight::AccessControls::Catalog

  include AuthenticationHelper

  copy_blacklight_config_from(CatalogController)

  before_action :authenticate_user!, except: [ 'development_login']
  before_action :find_collections, only: :gather_dashboard_information
  before_action :find_collections_with_edit_access, only: :gather_dashboard_information

  #blacklight_config.search_builder_class = ::MySearchBuilder

  #self.search_params_logic += [:add_access_controls_to_solr_params, :add_advanced_parse_q_to_solr]

  # Gathers all the information that we'll display in the user's dashboard.
  # Override this method if you want to exclude or gather additional data elements
  # in your dashboard view.  You'll need to alter dashboard/index.html.erb accordingly.

  def gather_dashboard_information

    @user = current_user

    (@response, @document_list) = search_results( params )

    # a draft thesis owned by me
    @theses = (@response.docs.map { |x| x if ( x.is_thesis? && x.is_draft? && x.is_mine?( current_user.user_key ) )}).select { |y| !y.nil? }

    @activity = current_user.all_user_activity(params[:since].blank? ? DateTime.now.to_i - Sufia.config.activity_to_show_default_seconds_since_now : params[:since].to_i)
    @notifications = current_user.mailbox.inbox
    @incoming = ProxyDepositRequest.where(receiving_user_id: current_user.id).reject(&:deleted_work?)
    @outgoing = ProxyDepositRequest.where(sending_user_id: current_user.id)
  end

  def development_login # TODO-PER: Temp route to get login working quickly.
    #if Rails.env.to_s == 'development'
      sign_in_user_id( params[:user] )
      redirect_to '/'
    #end
  end

  # GET /text_exception_notifier
  def test_exception_notifier
    raise "This is only a test of the automatic notification system."
  end

  # GET /test_email
  def test_email
    TestMailers.email().deliver_now
  end

end
