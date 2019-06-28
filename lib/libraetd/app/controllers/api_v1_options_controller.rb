require_dependency 'libraetd/lib/serviceclient/deposit_reg_client'

class APIV1OptionsController < APIBaseController

  #
  # get degree options
  #
  def degrees
    status, resp = ServiceClient::DepositRegClient.instance.list_deposit_options( )
    if ServiceClient::DepositRegClient.instance.ok?( status )
      render_options_response( :ok, resp['degrees'] )
    else
      render_options_response( status )
    end
  end

  #
  # get department options
  #
  def departments
    status, resp = ServiceClient::DepositRegClient.instance.list_deposit_options( )
    if ServiceClient::DepositRegClient.instance.ok?( status )
      render_options_response( :ok, resp['departments'] )
    else
      render_options_response( status )
    end
  end

  #
  # get language options
  #
  def languages
    options = LanguageService.select_active_options.map { |op| op[0] }
    render_options_response( :ok, options )
  end

  #
  # get rights options
  #
  def rights
    options = RightsService.select_active_options.map { |op| op[0] }
    render_options_response( :ok, options )
  end

  #
  # get embargo status options
  #
  def embargos
    options = {}
    options[:state_options] = ['No Embargo', 'UVA Only Embargo', 'Metadata Only Embargo' ]
    options[:period_options] = GenericWork.all_embargo_periods

    render_options_response( :ok, options )
  end

  private

  def render_options_response( status, options = [] )
    render json: API::OptionsListResponse.new( status, options ), :status => status
  end

end


