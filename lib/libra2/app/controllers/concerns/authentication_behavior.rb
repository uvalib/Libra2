module AuthenticationBehavior
	extend ActiveSupport::Concern

	included do
		before_action :require_netbadge
	end

	private

	def require_netbadge
		if user_signed_in?
			return
		end
		if Rails.env.to_s == 'development'
			@users = User.all
			@users = @users.map {|user| user.email.split("@")[0]  }
		else
			# redirect to https://netbadge.virginia.edu/
		end
	end

end
