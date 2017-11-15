require_dependency 'libraetd/lib/serviceclient/base_client'

module ServiceClient

   class DepositAuthClient < BaseClient

     #
     # configure with the appropriate configuration file
     #
     def initialize
       load_config( "depositauth.yml" )
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
     # get any requests later than the supplied request identifier (requests come in sequence)
     #
     def list_requests( id )
       url = "#{self.url}?auth=#{self.authtoken}&later=#{id}"
       status, response = rest_get( url )
       return status, response['details'] if ok?( status ) && response['details']
       return status, ''
     end

     #
     # get any requests that match the supplied computing Id
     #
     def search_requests( cid )
       url = "#{self.url}?auth=#{self.authtoken}&cid=#{cid}"
       status, response = rest_get( url )
       return status, response['details'] if ok?( status ) && response['details']
       return status, ''
     end

     #
     # get a specific request by id
     #
     def get_request( id )
       url = "#{self.url}/#{id}?auth=#{self.authtoken}"
       status, response = rest_get( url )
       return status, response['details'] if ok?( status ) && response['details']
       return status, ''
     end

     #
     # notify of a deposit
     #
     def request_fulfilled( work )
       url = "#{self.url}/#{work.sis_authorization_id}?auth=#{self.authtoken}&deposit=#{work.identifier}"
       status, _ = rest_put( url, nil )
       return status
     end

     #
     # initiate a SIS import
     #
     def import
       url = "#{self.url}/import?auth=#{self.authtoken}"
       status, response = rest_post( url, nil )
       if ok?( status )
          return status, response['new_count'], response['update_count'], response['duplicate_count'], response['error_count']
       end
       return status, 0, 0, 0, 0
     end

     #
     # initiate a SIS export
     #
     def export
       url = "#{self.url}/export?auth=#{self.authtoken}"
       status, response = rest_post( url, nil )
       if ok?( status )
          return status, response['export_count'], response['error_count']
       end
       return status, 0, 0
     end

     #
     # helpers
     #

     def authtoken
       configuration[ :authtoken ]
     end

     def url
       configuration[ :url ]
     end

   end
end
