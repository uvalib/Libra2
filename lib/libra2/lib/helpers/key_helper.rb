require_dependency 'libra2/lib/helpers/redis_helper'

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

    def value( key )
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
  end
end

#
# end of file
#