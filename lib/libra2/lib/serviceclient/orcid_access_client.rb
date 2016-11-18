require_dependency 'libra2/lib/serviceclient/base_client'

module ServiceClient

   class OrcidAccessClient < BaseClient

     #
     # configure with the appropriate configuration file
     #
     def initialize
       load_config( "orcidaccess.yml" )
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
     # get specified user's ORCID
     #
     def get_by_cid( id )
       url = "#{self.url}/cid/#{id}?auth=#{self.authtoken}"
       status, response = rest_get( url )
       return status, response['orcids'][ 0 ] if ok?( status ) && response['orcids']
       return status, ''
     end

     #
     # set specified user's ORCID
     #
     def set_by_cid( id, orcid )
       url = "#{self.url}/cid/#{id}/#{orcid}?auth=#{self.authtoken}"
       status, _ = rest_send( url, :put, nil )
       return status
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
