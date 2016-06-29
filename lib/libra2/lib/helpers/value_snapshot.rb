require_dependency 'libra2/lib/helpers/redis_helper'

module Helpers

  #
  # a simple abstraction of a persistent value
  # in this case, using Redis to store the current value
  #
  class ValueSnapshot

    include RedisHelper

     def initialize( key, default_value )
       @redis = nil
       @keyname = key
       return if redis_config( ) == false
       return if redis_connect( ) == false
       val = redis_get_value( @keyname )
       if val.nil?
         redis_set_value( @keyname, default_value )
       end
       redis_close( )
     end

     def val
       return nil if redis_connect( ) == false
       val = redis_get_value( @keyname )
       return nil if redis_close( ) == false
       #puts "READ key => [#{@keyname}], value => [#{val}]"
       return val
     end

     def val=( val )
       return if redis_connect( ) == false
       redis_set_value( @keyname, val )
       redis_close( )
       #puts "WRITE key => [#{@keyname}], value => [#{val}]"
     end

  end
end

#
# end of file
#