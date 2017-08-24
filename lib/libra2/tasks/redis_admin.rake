#
# Some helper tasks to manage Redis managed state
#

require_dependency 'libra2/lib/helpers/key_helper'

namespace :libraetd do

  namespace :redis do

  desc "Show deposit state keys"
  task show_deposit: :environment do |t, args|

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
  task show_timed: :environment do |t, args|

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

  desc "Show event keys"
  task show_event: :environment do |t, args|

    count = 0
    kh = Helpers::KeyHelper.new
    keys = kh.keys( "sufia:events:*" )
    if keys.nil? == false
      keys.each do |k|
        puts " #{k}"
        count += 1
      end
    end
    puts "#{count} key(s) listed"

  end

  desc "Show all keys; optionally provide a key pattern"
  task show_all: :environment do |t, args|

    pattern = ARGV[ 1 ]
    pattern = "*" if pattern.nil?

    task pattern.to_sym do ; end

    count = 0
    kh = Helpers::KeyHelper.new
    keys = kh.keys( pattern )
    if keys.nil? == false
      keys.each do |k|
        puts " #{k}"
        count += 1
      end
    end
    puts "#{count} key(s) listed"

  end

  desc "Delete a key (handle with care); provide the key to delete"
  task delete_one: :environment do |t, args|

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

  desc "Delete all keys (really handle with care); provide the key pattern to delete"
  task delete_all: :environment do |t, args|

    pattern = ARGV[ 1 ]
    if pattern.nil?
      puts "ERROR: no key pattern provided"
      next
    end

    task pattern.to_sym do ; end

    count = 0
    kh = Helpers::KeyHelper.new
    keys = kh.keys( pattern )
    if keys.nil? == false
      keys.each do |k|
        puts " #{k}"
        kh.delete( k )
        count += 1
      end
    end

    puts "#{count} key(s) deleted"

  end

  end   # namespace redis

end   # namespace libraetd

#
# end of file
#
