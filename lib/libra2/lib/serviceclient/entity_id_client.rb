require_dependency 'libra2/lib/serviceclient/service_client'

module ServiceClient

   class EntityIdClient < ServiceClientBase

     #
     # configure with the appropriate configuration file
     #
     def initialize
       load_config( "entityid.yml" )
     end

     #
     # singleton stuff
     #

     @@instance = EntityIdClient.new

     def self.instance
       return @@instance
     end

     private_class_method :new

     #
     # create a new DOI and associate any metadata we can determine from the supplied work
     #
     def newid( work )
       url = "#{self.url}/#{self.shoulder}?auth=#{self.authtoken}"
       payload =  self.construct_payload( work )
       status, response = rest_send( url, :post, payload )

       return status, response['details']['id'] if ok?( status ) && response['details'] && response['details']['id']
       return status, ''
     end

     #
     # update an existing DOI with any metadata we can determine from the supplied work
     #
     def metadatasync( work )
       url = "#{self.url}/#{work.identifier[ 0 ]}?auth=#{self.authtoken}"
       payload =  self.construct_payload( work )
       status, response = @client.rest_send( url, :put, payload )
       return status
     end

     #
     # remove a DOI entry
     #
     def remove( work )
       # not implemented
       500
     end

     #
     # construct the request payload
     #
     def construct_payload( work )
       h = {}
       h['title'] = work.title[ 0 ] if work.title[ 0 ] && work.title
       h['publisher'] = work.publisher if work.publisher
       h['creator'] = work.creator if work.creator
       h['url'] = work.relative_path if work.relative_path
       h['publication_year'] = '2016'
       h['type'] = work.resource_type if work.resource_type
       h.to_json
     end

     #
     # helpers
     #

     def shoulder
       configuration[ :shoulder ]
     end

     def authtoken
       configuration[ :authtoken ]
     end

     def url
       configuration[ :url ]
     end

   end
end
