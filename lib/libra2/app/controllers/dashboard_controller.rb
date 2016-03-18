class DashboardController < ApplicationController
  include Sufia::DashboardControllerBehavior

  include Blacklight::Configurable

  include Blacklight::SearchHelper
  include Blacklight::AccessControls::Catalog

  copy_blacklight_config_from(CatalogController)

  # Gathers all the information that we'll display in the user's dashboard.
  # Override this method if you want to exclude or gather additional data elements
  # in your dashboard view.  You'll need to alter dashboard/index.html.erb accordingly.

  def gather_dashboard_information

    @user = current_user

    (@response, @document_list) = search_results(params)
#    @theses = (@response.docs.map { |x| SolrDocument.new(x) if ((!x.work_type.nil? && x.work_type[0] == "thesis") && (!x.draft.nil? && x.draft[0] == "true"))}).select { |y| !y.nil?}
    @theses = (@response.docs.map { |x| SolrDocument.new(x) if ( x.is_thesis? && x.is_draft? )}).select { |y| !y.nil?}

    @activity = current_user.all_user_activity(params[:since].blank? ? DateTime.now.to_i - Sufia.config.activity_to_show_default_seconds_since_now : params[:since].to_i)
    @notifications = current_user.mailbox.inbox
    @incoming = ProxyDepositRequest.where(receiving_user_id: current_user.id).reject(&:deleted_work?)
    @outgoing = ProxyDepositRequest.where(sending_user_id: current_user.id)
  end

end
