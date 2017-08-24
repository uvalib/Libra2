require_dependency 'libraetd/lib/serviceclient/base_client'

module ServiceClient

   class AuthTokenClient < BaseClient

     #
     # configure with the appropriate configuration file
     #
     def initialize
       load_config( "authtoken.yml" )
     end

     #
     # singleton stuff
     #

     @@instance = new

     def self.instance
       return @@instance
     end

     private_class_method :new

     #
     # check the health of the endpoint
     #
     def healthcheck
       url = "#{self.url}/healthcheck"
       status, _ = rest_get( url )
       return( status )
     end

     #
     # get specified user information
     #
     def auth( who, what, token )
       url = "#{self.url}/authorize/#{who}/#{what}/#{token}"
       status, _ = rest_get( url )
       return status
     end

     #
     # helpers
     #

     def url
       configuration[ :url ]
     end

   end
end
