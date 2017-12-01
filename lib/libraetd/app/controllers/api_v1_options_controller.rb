require_dependency 'libraetd/lib/serviceclient/deposit_reg_client'

class APIV1OptionsController < APIBaseController

  #
  # get degree options
  #
  def degrees
    status, resp = ServiceClient::DepositRegClient.instance.list_deposit_options( )
    if ServiceClient::DepositRegClient.instance.ok?( status )
      options = extract_distinct_degrees( resp )
      render_options_response( :ok, options )
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
      options = extract_distinct_departments( resp )
      render_options_response( :ok, options )
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
    options = ['No Embargo', 'UVA Only Embargo', 'Metadata Only Embargo' ]
    render_options_response( :ok, options )
  end

  private

  def render_options_response( status, options = [] )
    render json: API::OptionsListResponse.new( status, options ), :status => status
  end

  #
  # extract a list of distinct degrees from the options response
  #
  def extract_distinct_degrees( options )
    degrees = []
    options.each do |o|
      options.each do |o|
        if o['degrees'].present?
          o['degrees'].each do |d|
            degrees << d
          end
        end
      end
    end

    return degrees.uniq
  end

  #
  # extract a list of distinct departments from the options response
  #
  def extract_distinct_departments( options )
    departments = []
    options.each do |o|
      departments << o['department'] if o['department'].present?
    end
    return departments.uniq
  end

end


