require 'redis'

module Helpers

  #
  # a simple abstraction of a persistent value
  # in this case, using a file to store the current value
  #
  class ValueSnapshot

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

     private

     def redis_connect
       begin
         @redis = Redis.new( :host => @host, :port => @port, :timeout => 2 )
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
     true
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

     def redis_config
       config = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access
       @host = config[:host]
       @port = config[:port]
       return true
     end
  end
end

#
# end of file
#