module Helpers

  #
  # a simple abstraction of a persistent value
  # in this case, using the filesystem to store the current value
  #
  class ValueSnapshot

     def initialize( key, default_value )
       @state_file = "#{Rails.root}/hostfs/state/#{key}.state"

       # we ensure it exists here and never check again
       if File.exist?( @state_file ) == false
         write_value( default_value )
       end
     end

     def val
       return read_value
     end

     def val=( val )
       write_value( val )
     end

     def read_value
       return IO.binread( @state_file )
     end

     def write_value( value )
       return IO.binwrite( @state_file, value )
     end
  end
end

#
# end of file
#