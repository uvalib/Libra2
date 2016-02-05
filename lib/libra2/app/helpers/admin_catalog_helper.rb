module AdminCatalogHelper

  def on_admin_catalog?
    params[:controller].match(/^admin\/catalog/)
  end

end
