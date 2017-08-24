require 'redis'

module Helpers

  #
  # helpers for using Redis
  #
  module RedisHelper

    def list_keys( pattern )
       begin
         return @redis.keys( pattern )
       rescue Exception => e
         puts e.message
       end
       return nil
    end

    def redis_get_value( key )
      begin
        return @redis.get( key )
      rescue Exception => e
        puts e.message
      end
      return nil
    end

    def redis_set_value( key, new_value )
      begin
        @redis.set( key, new_value )
      rescue Exception => e
        puts e.message
      end
    end

    def redis_set_ttl( key, ttl )
      begin
        @redis.expire( key, ttl )
      rescue Exception => e
        puts e.message
      end
    end

    def redis_get_ttl( key )
      begin
        return @redis.ttl( key )
      rescue Exception => e
        puts e.message
      end
      return nil
    end

    def redis_delete_key( key )
      begin
        @redis.del( key )
      rescue Exception => e
        puts e.message
      end
    end

    def redis_connect
       begin
         @redis = Redis.new( @redis_config.merge( :thread_safe => true ) )
         @redis.ping
         return true
       rescue Exception => e
         puts e.message
       end
       return false
    end

    def redis_close
       @redis.close( )
       @redis = nil
       return true
    end

    def redis_config
       @redis_config = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
       return true
    end
  end
end

#
# end of file
#