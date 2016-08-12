class APIV1DepositsController < APIBaseController

  #
  # get all deposits
  #
  def all_deposits
    render_deposits_response( :bad_request )
  end

  private

  def render_deposits_response( status, deposits = [] )
    render json: API::DepositListResponse.new( status, deposits ), :status => status
  end

end


