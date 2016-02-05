class AdminCatalogController < ::CatalogController

     def index
       @selected_tab = 'works'
       search_params_logic = [:add_access_controls_to_solr_params, :add_advanced_parse_q_to_solr]
       (@response, @document_list) = search_results(params, search_params_logic)
       @user = current_user

       #render ''
     end

end

