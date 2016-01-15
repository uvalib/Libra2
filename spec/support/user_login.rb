module UserLogin

  # Login as the user.  To be successful, the user's account must already
  # exist (i.e. already created).
  #
  # ==== Parameters
  #   @param [User] user
  #
  def login_as(user)
    # Go to login page, enter email and password, click log in button.
    visit user_session_path
    fill_in("user_email", :with => user.email)
    fill_in("user_password", :with => user.password)
    click_button("Log in")

    # Verification that login was successful.
    expect(page).to have_content("My Dashboard")
    expect(page).to have_content("Hello, #{user.email}")
  end

end
