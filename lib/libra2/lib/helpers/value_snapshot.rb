module Libra2

  #
  # a simple abstraction of a persistent value
  # in this case, using a file to store the current value
  #
  class ValueSnapshot

     def initialize( name, default_value )
       @filename = name
       @default = default_value
       return if File.exists?( @filename )
       File.open( @filename, "wb") do |file|
         file.puts @default
       end
     end

     def val
       File.open( @filename, "rb") do |file|
         val = file.gets.strip
         return @default if val.empty?
         return val
       end
     end

     def val=( val )
       File.open( @filename, "wb") do |file|
         file.puts val
       end
     end

  end
end
