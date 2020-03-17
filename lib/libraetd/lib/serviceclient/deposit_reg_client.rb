require_dependency 'libraetd/lib/serviceclient/base_client'

module ServiceClient

   class DepositRegClient < BaseClient

     #
     # configure with the appropriate configuration file
     #
     def initialize
       load_config( "depositreg.yml" )
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
     # get any pending requests later than the supplied request identifier (requests come in sequence)
     #
     def list_requests( id )
       url = "#{self.url}?auth=#{self.authtoken}&later=#{id}"
       status, response = rest_get( url )
       return status, response['details'] if ok?( status ) && response['details']
       return status, ''
     end

     #
     # list the options available for depositing
     #
     def list_deposit_options( )
       url = "#{self.url}/options"
       status, response = rest_get( url )
       return status, response['options'] if ok?( status ) && response['options']
       return status, ''
     end

     #
     # notify of a deposit
     #
     def request_fulfilled( work )
       # not implemented
       return 500
     end

     #
     # helpers
     #

     def url
       configuration[ :url ]
     end

   end
end
