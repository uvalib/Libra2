class APIV1DownloadsController < APIBaseController

  #
  # get content
  #
  def get_content
    send_file "#{Rails.application.root}/data/sample.pdf", :type => 'application/pdf', :disposition => 'inline'
  end

  #
  # get thumbnail
  #
  def get_thumbnail
    send_file "#{Rails.application.root}/data/sample.pdf", :type => 'application/pdf', :disposition => 'inline'
  end

  private

end


