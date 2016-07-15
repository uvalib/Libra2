#
#
#

require_dependency 'libra2/lib/helpers/etd_helper'

module TaskHelpers

  #
  # turn a computing ID into the format needed for the contributor field
  #
  def contributor_fields( computing_id )

    user = user_info_by_cid( computing_id )
    return nil if user.nil?
    return "#{computing_id}\n#{user.first_name}\n#{user.last_name}\n#{user.department}\n#{GenericWork::DEFAULT_INSTITUTION}"

  end

  #
  # get a work by the specified ID
  #
  def get_work_by_id( work_id )

     begin
       return GenericWork.find( work_id )
     rescue => e
     end

     return nil
  end

  #
  # download a random cat image
  #
  def get_random_image( )

    print "getting image... "

    dest_file = "#{File::SEPARATOR}tmp#{File::SEPARATOR}#{SecureRandom.hex( 5 )}.jpg"
    Net::HTTP.start( "lorempixel.com" ) do |http|
      resp = http.get("/640/480/cats/")
      open( dest_file, "wb" ) do |file|
        file.write( resp.body )
      end
    end
    puts "done"
    return dest_file

  end

  #
  # get user information from an email address
  #
  def user_info_by_email( email )
    id = User.cid_from_email( email )
    return user_info_by_cid( id )
  end

  #
  # get user information from a computing id
  #
  def user_info_by_cid( id )

    print "Looking up user details for #{id}..."

    # lookup the user by computing id
    user_info = Helpers::EtdHelper::lookup_user( id )
    if user_info.nil?
      puts "not found"
      return nil
    end

    puts "done"
    return user_info
  end

  def logme( prefix, message )

  end
end

#
# end of file
#