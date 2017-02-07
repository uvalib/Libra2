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
       return status, response['orcids'][0]['uri'] if ok?( status ) && response['orcids'] && response['orcids'][0] && response['orcids'][0]['uri']
       return status, ''
     end

     #
     # set specified user's ORCID
     #
     def set_by_cid( id, orcid )
       url = "#{self.url}/cid/#{id}/#{orcid}?auth=#{self.authtoken}"
       status, _ = rest_put( url, nil )
       return status
     end

     #
     # set specified user's ORCID
     #
     def search( search, start, max )
       url = "#{self.url}/orcid?q=#{search}&start=#{start}&max=#{max}&auth=#{self.authtoken}"
       status, response = rest_get( url )
       return status, response['results'] if ok?( status ) && response['results']
       return status, ''
     end

     #
     # get all known ORCID's
     #
     def get_all( )
       url = "#{self.url}/cid?auth=#{self.authtoken}"
       status, response = rest_get( url )
       return status, response['orcids'] if ok?( status ) && response['orcids']
       return status, ''
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
