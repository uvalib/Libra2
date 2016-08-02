#
#
#

require_dependency 'libra2/lib/helpers/etd_helper'

module TaskHelpers

  #
  # the default user for various admin activities
  #
  def default_user
    return 'dpg3k@virginia.edu'
  end

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

  #
  # upload the specified file to the specified work on behalf of the specified user
  #
  def upload_file( user, work, filename, title = nil )

    print "uploading #{filename}... "

    fileset = ::FileSet.new
    fileset.title << title unless title.nil?
    file_actor = ::CurationConcerns::Actors::FileSetActor.new( fileset, user )
    file_actor.create_metadata( work )
    file_actor.create_content( File.open( filename ) )

    puts "done"

  end

  #
  # delete the specified file from the specified work on behalf of the specified user
  #
  def delete_fileset( user, fileset )

    print "deleting file set #{fileset.id}... "

    file_actor = ::CurationConcerns::Actors::FileSetActor.new( fileset, user )
    file_actor.destroy

    puts "done"

  end

  #
  # list full details of a work
  #
  def list_full_work( work )

    return if work.nil?
    j = JSON.parse( work.to_json )
    j.keys.sort.each do |k|
      val = j[ k ]
      if k.end_with?( "_id" ) == false && val.nil? == false
        next if val.respond_to?( :empty? ) && val.empty? == true
        puts " #{k} => #{val}"
      end
    end
    puts " visibility => #{work.visibility}"
    puts " embargo_end_date => #{work.embargo_end_date}"
    puts " registrar_computing_id => #{work.registrar_computing_id}"
    puts " sis_id => #{work.sis_id}"
    puts " sis_entry => #{work.sis_entry}"

    if work.file_sets
      file_number = 1
      work.file_sets.each do |file_set|
        puts " file #{file_number} => #{file_set.label}/#{file_set.title[0]} (/downloads/#{file_set.id})"
        file_number += 1
      end
    end

    puts '*' * 40

  end

end

#
# end of file
#