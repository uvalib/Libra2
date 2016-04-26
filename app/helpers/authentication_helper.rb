module AuthenticationHelper

  def sign_in_user_id( id )
    return false if id.nil? || id.empty?
    users = User.find_by_sql( "select * from users where email LIKE '%#{id}%' LIMIT 1" )
    if users.length == 1
      sign_in( users[ 0 ], :bypass => true )
      return true
    end
    return false
  end

end
