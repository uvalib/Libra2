module AuthenticationBehavior
	extend ActiveSupport::Concern

	included do
		before_action :require_auth
	end

	private

	def require_auth

    #
    # if the user is already signed in, then we are good...
    #
		if user_signed_in?
			return
		end

    #
    # check the request environment and see if we have a user defined by netbadge
    #
     if request.env['HTTP_REMOTE_USER'].present?
       puts "=====> HTTP_REMOTE_USER: #{request.env['HTTP_REMOTE_USER']}"
	   begin
		   # TODO-PER: This fails when called when requesting the favicon. I'm not sure why, but the errors are obscuring real system errors.
		   return if sign_in_user_id( request.env['HTTP_REMOTE_USER'] )
	   rescue
		   return false
	   end
    end

    puts "=====> HTTP_REMOTE_USER NOT defined"

    #
    # a hack to allow us to login without netbadge
    #
    if ENV['ALLOW_FAKE_NETBADGE'] == 'true'
			@users = User.order( :email )
			@users = @users.map {|user| user.email.split("@")[0] }
    else
      raise ActionController::RoutingError.new( 'Forbidden' )
    end

	end

end
