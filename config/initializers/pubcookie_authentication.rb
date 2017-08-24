module Pubcookie

  # Pubcookie Strategy borrowed from https://github.com/uvalib/geoblacklight
  class CustomStrategy < Devise::Strategies::Authenticatable

    def valid?
      # We want this strategy to be valid for any request with this header set
      # so that we can use a custom response for an invalid request.
      # cookies['pubcookie_s_geoblacklight'].present?

      # we seem to have cases where this field is populated with the string '(null)'
      # might be an Apache rewrite issue... anyway, check for it here...
      valid = request.env[pubcookie_user].present? && request.env[pubcookie_user] != '(null)'
      return valid
    end

    # it must have an authenticate! method to perform the validation
    # a successful request calls `success!` with a user object to stop
    # other strategies and set up the session state for the user logged in
    # with that user object.
    def authenticate!

      # mapping comes from devise base class, "mapping.to" is the class of the model
      # being used for authentication, typically the class "User".
      # This is set by using the `devise` class method in that model
      klass = mapping.to

      if authorized_user?
        email = klass.email_from_cid( request.env[pubcookie_user] )
        user = klass.find_by( email: email )
        # not for libra ETD
        #user = klass.create_user( email ) unless user
        if user.present?
          success! user
        else
          fail!
        end
      else
        fail!
      end

      # if we wanted to stop other strategies from authenticating the user
    end

    private

    def pubcookie_user
      @pubcookie_user ||= "HTTP_REMOTE_USER".freeze
    end

    def authorized_user?
      user = request.env[pubcookie_user]
      # Checking for valid LDAP should go below
      # possibly returning the user instead of a boolean
      if user.present?
        true

      else
        fail!
        false
      end
    end
  end
end

# for warden, `:pubcookie_authentication`` is just a name to identify the strategy
Warden::Strategies.add :pubcookie_authentication, Pubcookie::CustomStrategy

# for devise, there must be a module named 'PubcookieAuthentication'
# (name.to_s.classify), and then it looks to warden for that strategy.
# This strategy will only be enabled for models using
# devise and `:pubcookie_authentication` as an option in
# the `devise` class method within the model.
Devise.add_module :pubcookie_authentication, strategy: true
