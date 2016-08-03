#
# Some helper tasks to download files
#

require 'net/scp'

namespace :libra2 do

  namespace :download do

  @dev_hostname = 'docker1.lib.virginia.edu'
  @prod_hostname = 'dockerprod1.lib.virginia.edu'

  @dev_root = '/docker/libra2/uploads/originals'
  @prod_root = '/lib_content22/libra2/uploads/originals'

  desc "Download all files for the specified work; must provide the work id. Optionally provide target directory and scp username"
  task work_download: :environment do |t, args|

    work_id = ARGV[ 1 ]
    if work_id.nil?
      puts "ERROR: no work id specified, aborting"
      next
    end

    task work_id.to_sym do ; end

    target_dir = ARGV[ 2 ]
    if target_dir.nil?
      target_dir = '.'
    end

    task target_dir.to_sym do ; end

    username = ARGV[ 3 ]
    if username.nil?
      username = 'dpg3k'
    end

    task username.to_sym do ; end

    work = TaskHelpers.get_work_by_id( work_id )
    if work.nil?
      puts "ERROR: work #{work_id} does not exist, aborting"
      next
    end

    if work.file_sets
      work.file_sets.each do |file_set|
        download_fileset( file_set, target_dir, username )
      end
    end

  end

  def download_fileset( fileset, target_dir, username )

    src_name = "#{dir_from_fileset_id fileset.id}/#{fileset.label}"
    dst_name = "#{target_dir}/#{fileset.label}"

    # try production first
    if scp_file( @prod_hostname, username, "#{@prod_root}/#{src_name}", dst_name ) == false
       # then try development
       scp_file( @dev_hostname, username, "#{@dev_root}/#{src_name}", dst_name )
    end

  end

  def scp_file( hostname, username, src, dst )

      begin
         Net::SCP.download!( hostname, username, src, dst )
         puts "  scp #{username}@#{hostname}:#{src} => #{dst} OK"
         return true
      rescue => e
         puts "  scp #{username}@#{hostname}:#{src} => #{dst} ERROR"
         return false
      end

  end

  def dir_from_fileset_id( id )
      return "#{id[0]}#{id[1]}/#{id[2]}#{id[3]}/#{id[4]}#{id[5]}/#{id[6]}#{id[7]}"
  end

end   # namespace download

end   # namespace libra2

#
# end of file
#
