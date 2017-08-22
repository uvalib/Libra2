class OrcidController < ApplicationController

  ORCID_MESSAGE= '<a href="http://www.library.virginia.edu/libra/orcid-at-uva/" target="_blank">Click here for more information about how Libra works with your ORCID ID.</a>'

  def landing
    orcid_response = orcid_token_exchange
    body = JSON.parse orcid_response.body

    if orcid_response.code == 200 && apply_orcid(body)
      redirect_to root_url, notice: "Your ORCID account was successfully linked."
    else
      error = params['error_description']
      redirect_to root_url, alert: "There was a problem linking your ORCID account. #{error}. " + ORCID_MESSAGE
    end
  end

  def destroy
    if current_user.update(orcid: nil, orcid_access_token: nil, orcid_refresh_token: nil,
                           orcid_scope: nil, orcid_expires_at: nil, orcid_linked_at: nil
                          )
      flash[:notice] = 'Your ORCID ID was successfully removed'
      redirect_to sufia.profile_path(current_user)
    else
      flash[:error] = 'The was a problem removing your ORCID ID'
      redirect_to sufia.edit_profile_path(current_user)
    end
  end

  private
  def orcid_token_exchange
    begin
    RestClient.post("#{ENV['ORCID_BASE_URL']}/oauth/token", {
        client_id: ENV['ORCID_CLIENT_ID'],
        client_secret: ENV['ORCID_CLIENT_SECRET'],
        grant_type: 'authorization_code',
        code: params['code'],
        redirect_uri: orcid_landing_url
      }, {accept: :json}
    )
    rescue RestClient::Exception => e
      return e.response
    end
  end

  def apply_orcid o_response

    # Check for required keys
    unless (%w(orcid access_token refresh_token expires_in) - o_response.keys).empty?
      flash['error'] = "ORCID's response was invalid."
      return false
    end

    # Check for temporary auth
    expires_in = o_response['expires_in']
    one_time_access = expires_in.seconds < 1.day
    if one_time_access
      flash['error'] = 'Please be sure to leave "Allow this permission until I revoke it" checked on the ORCID authorization page.'
      return false
    end

    expires_at = DateTime.current + expires_in.seconds
    current_user.update(orcid: o_response['orcid'], orcid_access_token: o_response['access_token'],
                        orcid_refresh_token: o_response['refresh_token'],
                        orcid_expires_at: expires_at, orcid_linked_at: DateTime.current,
                        orcid_scope: o_response['scope']
                       )
  end
end
