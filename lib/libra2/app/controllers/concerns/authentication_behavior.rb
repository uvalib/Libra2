module AuthenticationBehavior
	extend ActiveSupport::Concern

	included do
		before_action :require_netbadge
	end

	private

	def require_netbadge

    #
    # if the user is already signed in, then we are good...
    #
		if user_signed_in?
			return
		end

    #
    # check the request environment and see if we have a user defined by netbadge
    #
    #request.env['HTTP_REMOTE_USER'] = 'dpg3k'
    if request.env['HTTP_REMOTE_USER'].present?
       puts "=====> HTTP_REMOTE_USER: #{request.env['HTTP_REMOTE_USER']}"
       return if sign_in_user_id( request.env['HTTP_REMOTE_USER'] )
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
