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
     keys.each do |k|
       puts " #{k} => value #{kh.value( k )}"
       count += 1
     end
     puts "#{count} key(s) listed"
  end

  desc "Show timed token keys"
  task timed: :environment do |t, args|

    count = 0
    kh = Helpers::KeyHelper.new
    keys = kh.keys( "libra2:*:timed:*" )
    keys.each do |k|
      puts " #{k} => ttl #{kh.ttl( k )}"
      count += 1
    end
    puts "#{count} key(s) listed"

  end

  end   # namespace state

end   # namespace libra2

#
# end of file
#
