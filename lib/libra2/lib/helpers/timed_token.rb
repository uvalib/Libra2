require_dependency 'libra2/lib/helpers/redis_helper'

module Helpers

  #
  # a simple abstraction of a timed token
  # in this case, using Redis
  #
  class TimedToken

    include RedisHelper

    def initialize( key, ttl )
       @redis = nil
       @keyname = key
       @ttl = ttl
       @is_mine = false
       return if redis_config( ) == false
       return if redis_connect( ) == false
       val = redis_get_value( @keyname )
       if val.nil?
         @is_mine = true
         redis_set_value( @keyname, 0 )
         redis_set_ttl( @keyname, ttl )
       end
       redis_close( )
    end

    def is_available?
      return true if @is_mine == true
      return false if redis_connect( ) == false
      val = redis_get_value( @keyname )
      return false if redis_close( ) == false
      return val.nil?
    end

    def release
      return if @is_mine == false
      return if redis_connect( ) == false
      redis_delete_key( @keyname )
      redis_close( )
    end

  end
end

#
# end of file
#