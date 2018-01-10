require_dependency 'libraetd/lib/helpers/redis_helper'

module Helpers

  class KeyHelper

    include RedisHelper

    def initialize( )
      redis_config( )
    end

    def keys( pattern )
       return nil if redis_connect( ) == false
       keys = list_keys( pattern )
       return nil if redis_close( ) == false
       return keys
    end

    def set_value( key, value )
      return if redis_connect( ) == false
      redis_set_value( key, value )
      redis_close( )
    end

    def get_value( key )
      return nil if redis_connect( ) == false
      val = redis_get_value( key )
      return nil if redis_close( ) == false
      return val
    end

    def ttl( key )
      return nil if redis_connect( ) == false
      val = redis_get_ttl( key )
      return nil if redis_close( ) == false
      return val
    end

    def delete( key )
      return if redis_connect( ) == false
      redis_delete_key( key )
      redis_close( )
    end
  end
end

#
# end of file
#