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
    #request.env['REMOTE_USER'] = 'dpg3k'
    if request.env['REMOTE_USER'].present?
       puts "=====> REMOTE_USER: #{request.env['REMOTE_USER']}"
       return if sign_in_user_id( request.env['REMOTE_USER'] )
    end

    puts "=====> REMOTE_USER NOT defined"

    if request.env['REQUEST_URI'].include? '/sign_in'
       puts "=====> Dumping request environment"
       request.env.keys.each do | k|
         puts "#{k} -> #{request.env[k]}"
       end
    end

    #
    # a hack to allow us to login without netbadge
    #
		if Rails.env.to_s == 'development'
			@users = User.order( :email )
			@users = @users.map {|user| user.email.split("@")[0] }
    end

	end

end
