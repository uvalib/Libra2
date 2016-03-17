require_dependency 'libra2/lib/serviceclient/service_client'

module ServiceClient

   class DepositRegClient

     #
     # configure with the appropriate configuration file
     #
     def initialize
       @client = ServiceClient.new( "depositreg.yml" )
     end

     #
     # singleton stuff
     #

     @@instance = DepositRegClient.new

     def self.instance
       return @@instance
     end

     private_class_method :new

     #
     # get any pending requests later than the supplied request identifier (requests come in sequence)
     #
     def list_requests( id )
       url = "#{self.url}?auth=#{self.authtoken}&later=#{id}"
       status, response = @client.rest_get( url )
       return status, response['details'] if ok?( status ) && response['details']
       return status, ''
     end

     #
     # notify of a deposit
     #
     def request_fulfilled( work )
       # not implemented
       500
     end

     #
     # construct the request payload
     #
     def construct_payload( work )
       h = {}
       h.to_json
     end

     #
     # helpers
     #

     def ok?( status )
       @client.ok?( status )
     end

     def authtoken
       @client.configuration[ :authtoken ]
     end

     def url
       @client.configuration[ :url ]
     end

   end
end
