#
# Some helper tasks to manage Redis managed state
#

require_dependency 'libraetd/lib/helpers/key_helper'

namespace :libraetd do

  namespace :redis do

  desc "Show deposit state keys"
  task show_deposit: :environment do |t, args|

     count = 0
     kh = Helpers::KeyHelper.new
     keys = kh.keys( "libra2:*:deposit:*" )
     if keys.nil? == false
       keys.each do |k|
         puts " #{k} => value #{kh.get_value( k )}"
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

  desc "Clone a key (handle with care); provide the source key and the clone name"
  task clone_one: :environment do |t, args|

    source_key = ARGV[ 1 ]
    if source_key.nil?
      puts "ERROR: no source key provided"
      next
    end

    task source_key.to_sym do ; end

    cloned_key = ARGV[ 2 ]
    if cloned_key.nil?
      puts "ERROR: no clone key provided"
      next
    end

    task cloned_key.to_sym do ; end

    kh = Helpers::KeyHelper.new
    val = kh.get_value( source_key )
    kh.set_value( cloned_key, val )
    puts "#{source_key} cloned to #{cloned_key}; value #{val}"

  end

  end   # namespace redis

end   # namespace libraetd

#
# end of file
#
