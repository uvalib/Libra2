require 'securerandom'

module UploadCacheBehavior
    extend ActiveSupport::Concern

    included do

      #
      # generates a new cache location
      #
      def self.new_cache
        self.purge_cache
        return File.join( cache_dir, SecureRandom.hex( 5 ) )
      end

      #
      # returns the full name of the file in the cache
      #
      def self.cache_contents( id )
        dirname = File.join( cache_dir, id )
        if Dir.exist?( dirname )
          Dir.foreach( dirname ) do |item|
            next if item == '.' or item == '..'
            return File.join( dirname, item )
          end
        end
        return ''
      end

      #
      # get cache key from the url
      #
      def self.cache_key_from_url( url )
        return File.basename( File.dirname( url ) )
      end

      #
      # get cache filename from the url
      #
      def self.cache_file_from_url( url )
        return File.basename( url )
      end
      #
      # base directory name for the cache
      #
      def self.cache_dir
        return File.join( Rails.root, 'hostfs', 'uploads', 'admin' )
      end

      private

      #
      # purge the cache of any stale stuff
      #
      def self.purge_cache

        max_cache_age = 300 # seconds

        basedir = self.cache_dir
        Dir.foreach( basedir ) do |item|
          next if item == '.' or item == '..'
          ftime = File.ctime( File.join( basedir, item ) )
          age = Time.now.to_i - ftime.to_i
          if age > max_cache_age
             dirname = File.join( basedir, item )
             puts "purging upload cache (#{dirname}) because it is #{age} seconds old"
             FileUtils.rm_rf( dirname )
          end
        end
      end

    end

end
