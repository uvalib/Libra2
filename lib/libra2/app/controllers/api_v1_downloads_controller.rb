class APIV1DownloadsController < APIBaseController

  #
  # get content
  #
  def get_content
    render_deposits_response( :bad_request )
  end

  #
  # get thumbnail
  #
  def get_thumbnail
    render_deposits_response( :bad_request )
  end

  private

  def render_deposits_response( status, deposits = [] )
    render json: API::DepositListResponse.new( status, deposits ), :status => status
  end

end


