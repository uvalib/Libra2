require_dependency 'libraetd/lib/helpers/etd_helper'

class DashboardController < ApplicationController
  include Sufia::DashboardControllerBehavior

  include Blacklight::Configurable

  include Blacklight::SearchHelper
  include Blacklight::AccessControls::Catalog

  include AuthenticationHelper
  include ::UpdateOrcidBehavior

  copy_blacklight_config_from(CatalogController)

  before_action :authenticate_user!, except: [ 'development_login']
  before_action :find_collections, only: :gather_dashboard_information
  before_action :find_collections_with_edit_access, only: :gather_dashboard_information
  before_action :sync_orcid_info, only: :index

  #blacklight_config.search_builder_class = ::MySearchBuilder

  #self.search_params_logic += [:add_access_controls_to_solr_params, :add_advanced_parse_q_to_solr]

  # Gathers all the information that we'll display in the user's dashboard.
  # Override this method if you want to exclude or gather additional data elements
  # in your dashboard view.  You'll need to alter dashboard/index.html.erb accordingly.

  def gather_dashboard_information

    @user = current_user
    (@response, @document_list) = search_results( q: "#{Solrizer.solr_name( 'depositor' )}:#{current_user.email}",
                                                  sort: "#{Solrizer.solr_name('system_create', :stored_sortable, type: :date)} desc",
                                                  rows: 999 )

    # a draft thesis owned by me
    #puts "===> query returns #{@response.docs.empty? ? "0" : @response.docs.size} item(s)"

    @draft_theses = (@response.docs.map { |x| x if ( x.is_thesis? )}).select { |y| !y.nil? }
    #puts "===> filtered returns #{@draft_theses.empty? ? "0" : @draft_theses.size} item(s)"

    @activity = [] # don't show any activity.
    @notifications = current_user.mailbox.inbox
    @incoming = ProxyDepositRequest.where(receiving_user_id: current_user.id).reject(&:deleted_work?)
    @outgoing = ProxyDepositRequest.where(sending_user_id: current_user.id)
  end

  def development_login # TODO-PER: Temp route to get login working quickly.
    if ENV['ENABLE_TEST_FEATURES'].present?
      sign_in_user_id( params[:user] )
      redirect_to '/'
    end
  end

  def logout

    # do devise stuff
    sign_out current_user

    # if we are not in development, redirect to ship logout url
    if Rails.env.development? == false
      redirect_to "#{main_app.root_url}/Shibboleth.sso/Logout?return=http://libra.virginia.edu"
    else
      redirect_to '/'
    end

  end

  # GET /text_exception_notifier
  def test_exception_notifier
    raise "This is only a test of the automatic notification system."
  end

  # GET /test_email
  def test_email
    TestMailers.email( EXCEPTION_RECIPIENTS, MAIL_SENDER, 'Libra2 Test Email' ).deliver_later
  end

  # GET /computing_id
  def computing_id
    respond_to do |wants|
      wants.json {
        status, resp = ServiceClient::UserInfoClient.instance.get_by_id( params[:id] )
        if ServiceClient::UserInfoClient.instance.ok?( status ) && resp['private'] != 'true'

           resp[:institution] = GenericWork::DEFAULT_INSTITUTION
           resp[:index] = params[:index]
        else
           resp = { }
        end
        render json: resp, status: :ok
      }
    end
  end

  # GET /orcid_search
  def orcid_search
    respond_to do |wants|
      wants.json {
        params[:start] = '0' unless params[:start]
        params[:max] = '25' unless params[:max]
        status, resp = ServiceClient::OrcidAccessClient.instance.search( params[:q], params[:start], params[:max] )
        if ServiceClient::OrcidAccessClient.instance.ok?( status )
        else
          resp = { }
        end
        render json: resp, status: :ok
      }
    end
  end

end
