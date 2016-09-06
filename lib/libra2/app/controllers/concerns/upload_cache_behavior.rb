require 'securerandom'

module UploadCacheBehavior
    extend ActiveSupport::Concern

    #
    # generates a new cache location
    #
    def new_cache
      return File.join( cache_dir, SecureRandom.hex( 5 ) )
    end

    #
    # returns the full name of the file in the cache
    #
    def cache_contents( id )
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
    def cache_key_from_url( url )
      return File.basename( File.dirname( url ) )
    end

    #
    # get cache filename from the url
    #
    def cache_file_from_url( url )
      return File.basename( url )
    end

    #
    # base directory name for the cache
    #
    def cache_dir
      return File.join( Rails.root, 'hostfs', 'uploads', 'admin' )
    end

    #
    # purge the cache of any stale stuf
    #
    def purge_cache

    end

    private

end
