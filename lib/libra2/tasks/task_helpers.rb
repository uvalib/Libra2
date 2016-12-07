#
#
#

require 'oga'
require 'net/scp'

require_dependency 'libra2/lib/helpers/etd_helper'

module TaskHelpers

  # used for the extract/ingest processing
  DOCUMENT_ID_FILE = 'id.json'
  DOCUMENT_FILES_LIST = 'filelist.txt'
  DOCUMENT_JSON_FILE = 'data.json'
  DOCUMENT_XML_FILE = 'data.xml'
  DOCUMENT_HTML_FILE = 'data.html'

  # general definitions
  DEFAULT_USER = 'dpg3k'
  DEFAULT_DOMAIN = 'virginia.edu'

  #
  # the default user for various admin activities
  #
  def default_user_email
    return default_email( DEFAULT_USER )
  end

  #
  # construct a default email address given a computing Id
  #
  def default_email( cid )
    return "#{cid}@#{DEFAULT_DOMAIN}"
  end

  #
  # turn a computing ID into the format needed for the contributor field
  # we provide a number to allow us to determine order intent. Underlying storage prevents us
  # from assuming order based on position in the array
  #
  def contributor_fields_from_cid( index, computing_id )
    user = user_info_by_cid( computing_id )
    return nil if user.nil?
    return contributor_fields( index, computing_id, user.first_name, user.last_name, user.department, GenericWork::DEFAULT_INSTITUTION )
  end

  #
  # concat the contributor fields together to for the aggregate contributor field
  #
  def contributor_fields( index, computing_id, first_name, last_name, department, institution )
    return "#{index}\n#{computing_id}\n#{first_name}\n#{last_name}\n#{department}\n#{institution}"
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
  def upload_file( user, work, filename, title, visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC )

    print "uploading #{filename}... "

    fileset = ::FileSet.new
    fileset.title << title unless title.nil?
    file_actor = ::CurationConcerns::Actors::FileSetActor.new( fileset, user )
    file_actor.create_metadata( work )
    file_actor.create_content( File.open( filename ) )
    fileset.visibility = visibility
    fileset.save!

    puts "done"
    return fileset

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
  # batch process a group of SOLR works
  #
  def batched_process_solr_works( solr_works, &f )

    solr_works.each do |gw_solr|
      begin
        gw = GenericWork.find( gw_solr['id'] )
        f.call( gw )
      rescue => e
        puts e
      end
    end

  end

  #
  # show full details of a generic work
  #
  def show_generic_work( work )

    return if work.nil?
    j = JSON.parse( work.to_json )
    j.keys.sort.each do |k|
      val = j[ k ]
      if k.end_with?( "_id" ) == false
        show_field( k, val )
      end
    end

    show_field( 'visibility', work.visibility )
    #show_field( 'embargo_end_date', work.embargo_end_date )
    #show_field( 'embargo_release_date', work.embargo_end_date )
    show_field( 'registrar_computing_id', work.registrar_computing_id )
    show_field( 'sis_id', work.sis_id )
    show_field( 'sis_entry', work.sis_entry )

    if work.file_sets
      file_number = 1
      work.file_sets.each do |file_set|
        puts " file #{file_number} => #{file_set.label}/#{file_set.title[0]} (/downloads/#{file_set.id})"
        file_number += 1
      end
    end

    puts '*' * 40

  end

  #
  # show a field if it is not empty
  #
  def show_field( name, val )
    return if val.nil?
    return if val.respond_to?( :empty? ) && val.empty?
    puts " #{name} => #{val}"
  end

  #
  # download a fileset from the server
  #
  def download_fileset( fileset, target_dir, username )

    #
    # hardcoded host names
    #
    dev_hostname = 'docker1.lib.virginia.edu'
    prod_hostname = 'dockerprod1.lib.virginia.edu'

    #
    # hardcoded directory names
    #
    dev_root = '/docker/libra2/uploads/originals'
    prod_root = '/lib_content22/libra2/uploads/originals'

    src_name = "#{dir_from_fileset_id fileset.id}/#{fileset.label}"
    dst_name = "#{target_dir}/#{fileset.label}"

    #puts "  downloading fileset #{fileset.id}..."

    # try production first
    if scp_file( prod_hostname, username, "#{prod_root}/#{src_name}", dst_name ) == false
      # then try development
      if scp_file( dev_hostname, username, "#{dev_root}/#{src_name}", dst_name ) == false
        puts "ERROR: downloading #{src_name}"
        return false
      end
    end

    return true
  end

  #
  # copy a local fileset
  #
  def copy_local_fileset( fileset, target_dir )

    src_name = "#{CurationConcerns.config.working_path}/#{dir_from_fileset_id fileset.id}/#{fileset.label}"
    dst_name = "#{target_dir}/#{fileset.label}"

    puts "  copying fileset #{fileset.id}..."
    begin
      FileUtils.cp src_name, dst_name
      puts "  cp #{src_name} => #{dst_name} OK"
      return true
    rescue => e
      #puts "  cp #{src_name} => #{dst_name} ERROR"
      return false
    end

  end

  #
  #
  #
  def scp_file( hostname, username, src, dst )

    begin
      Net::SCP.download!( hostname, username, src, dst )
      puts "  scp #{username}@#{hostname}:#{src} => #{dst} OK"
      return true
    rescue => e
      #puts "  scp #{username}@#{hostname}:#{src} => #{dst} ERROR"
      return false
    end

  end

  #
  # create the local work directory based on the fileset id
  #
  def dir_from_fileset_id( id )
    return "#{id[0]}#{id[1]}/#{id[2]}#{id[3]}/#{id[4]}#{id[5]}/#{id[6]}#{id[7]}"
  end

  #
  # get a list of assets in the specified directory that match the supplied pattern
  #
  def get_directory_list( dirname, pattern )
    res = []
    begin
      Dir.foreach( dirname ) do |f|
        if pattern.match( f )
          res << f
        end
      end
    rescue => e
    end

    return res.sort { |x, y| directory_sort_order( x, y ) }
  end

  #
  # so we can process the directories in numerical order
  #
  def directory_sort_order( f1, f2 )
    n1 = File.extname( f1 ).gsub( '.', '' ).to_i
    n2 = File.extname( f2 ).gsub( '.', '' ).to_i
    return -1 if n1 < n2
    return 1 if n1 > n2
    return 0
  end

  #
  # load a file containing json data and return a hash
  #
  def load_json_doc( filename )
    File.open( filename, 'r') do |file|
      json_str = file.read( )
      doc = JSON.parse json_str
      return doc
    end
  end

  #
  # load a file containing xml data and return an oga document
  #
  def load_xml_doc( filename )
    File.open( filename, 'r') do |file|
      return Oga.parse_xml( file )
    end
  end

end

#
# end of file
#