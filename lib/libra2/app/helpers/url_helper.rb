module UrlHelper

  def fully_qualified_work_url( id )
    "#{public_site_url}#{locally_hosted_work_url( id )}"
  end

  def locally_hosted_work_url( id )
    "/public_view/#{id}"
  end

  def public_site_url
    #TODO-DPG: fix this appropriatly
    "https://libra2dev.lib.virginia.edu"
  end

  def doi_work_url( doi )
    #TODO-DPG: fix this appropriatly
    "/DOI/#{doi}"
  end

end
