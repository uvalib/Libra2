#
# Some helper tasks to manage Redis managed state
#

require_dependency 'libra2/lib/helpers/key_helper'

namespace :libra2 do

  namespace :state do

  desc "Show deposit state keys"
  task deposit: :environment do |t, args|

     count = 0
     kh = Helpers::KeyHelper.new
     keys = kh.keys( "libra2:*:deposit:*" )
     if keys.nil? == false
       keys.each do |k|
         puts " #{k} => value #{kh.value( k )}"
         count += 1
       end
     end
     puts "#{count} key(s) listed"
  end

  desc "Show timed token keys"
  task timed: :environment do |t, args|

    count = 0
    kh = Helpers::KeyHelper.new
    keys = kh.keys( "libra2:*:timed:*" )
    if keys.nil? == false
      keys.each do |k|
        puts " #{k} => ttl #{kh.ttl( k )}"
        count += 1
      end
    end
    puts "#{count} key(s) listed"

  end

  desc "Delete a key (handle with care); provide the key to delete"
  task delete: :environment do |t, args|

    key = ARGV[ 1 ]
    if key.nil?
      puts "ERROR: no key provided"
      next
    end

    task key.to_sym do ; end

    kh = Helpers::KeyHelper.new
    kh.delete( key )
    puts "#{key} deleted"

  end

  end   # namespace state

end   # namespace libra2

#
# end of file
#
