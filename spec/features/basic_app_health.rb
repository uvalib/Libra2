require_relative 'feature_spec_helper'

describe 'Generic health test of app running:', :type => :feature do

  context 'App is running' do
    let!(:current_user) { create :user }

    # Even though the login_as is a helper for other tests, it is being used
    # here as the simple test of whether the app is alive or not.
    specify 'and a user can login and see his dashboard' do
      login_as(current_user)
    end

  end
end

