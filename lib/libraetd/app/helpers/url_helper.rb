require 'socket'

module UrlHelper

  def fully_qualified_work_url( id )
    "#{public_site_url}#{locally_hosted_work_url( id )}"
  end

  def locally_hosted_work_url( id )
    "/public_view/#{id}"
  end

  def public_site_url
    return "#{protocol}://#{hostname}"
  end

  private

  def hostname
    return Socket.gethostname unless Rails.env.to_s == 'development'
    return 'localhost:3000'
  end

  def protocol
    return 'https' unless Rails.env.to_s == 'development'
    return 'http'
  end
end
