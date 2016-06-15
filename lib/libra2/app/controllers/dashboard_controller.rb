require_dependency 'libra2/lib/helpers/etd_helper'

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
    (@response, @document_list) = search_results( q: "depositor_ssim:#{current_user.email}", rows: 100 )

    # a draft thesis owned by me
    #puts "===> query returns #{@response.docs.empty? ? "0" : @response.docs.size} item(s)"

    @draft_theses = (@response.docs.map { |x| x if ( x.is_thesis? )}).select { |y| !y.nil? }
    #puts "===> filtered returns #{@draft_theses.empty? ? "0" : @draft_theses.size} item(s)"

    @activity = current_user.all_user_activity(params[:since].blank? ? DateTime.now.to_i - Sufia.config.activity_to_show_default_seconds_since_now : params[:since].to_i)
    #@activity has a number of links built into it. Strip out all links, and when it is refers to a file, also change the file to its filename.
    # @activity is an array of [ {:action, :timestamp }]
    # The action might include some links, and the address of a file in plain text, so we'll get rid of the plain text address, then remove all html.
    @activity.each { |activity|
      activity[:action] = activity[:action].gsub(/\/concern\/file_sets\/\w+/, "a file")
      activity[:action] = ActionView::Base.full_sanitizer.sanitize(activity[:action])
    }
    @notifications = current_user.mailbox.inbox
    @incoming = ProxyDepositRequest.where(receiving_user_id: current_user.id).reject(&:deleted_work?)
    @outgoing = ProxyDepositRequest.where(sending_user_id: current_user.id)
  end

  def development_login # TODO-PER: Temp route to get login working quickly.
    if ENV['ALLOW_FAKE_NETBADGE'] == 'true'
      sign_in_user_id( params[:user] )
      redirect_to '/'
    end
  end

  def logout

    # do devise stuff
    sign_out current_user

    # if we are not in development, redirect to ship logout url
    if ENV['RAILS_ENV'] != 'development'
      redirect_to "#{main_app.root_url}Shibboleth.sso/Logout?return=http://libra.virginia.edu"
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
    TestMailers.email().deliver_now
  end

  # GET /computing_id
  def computing_id
    respond_to do |wants|
      wants.json {
        status, resp = ServiceClient::UserInfoClient.instance.get_by_id( params[:id] )
        if status == 404
          resp = { }
        else
            resp[:institution] = "University of Virginia"
            resp[:index] = params[:index]
        end
        render json: resp, status: :ok
      }
    end
  end
end
