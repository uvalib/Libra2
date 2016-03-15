require "#{Rails.root}/lib/libra2/lib/serviceclient/service_client"

module Libra2

   class EntityIdClient < ServiceClient

     #
     # configure the appropriate configuration file
     #
     class << self
       ServiceClient.config_file = "entityid.yml"
     end

     #
     # create a new DOI and associate any metadata we can determine from the supplied work
     #
     def self.newid( work )
       url = "#{EntityIdClient.url}/#{EntityIdClient.shoulder}?auth=#{EntityIdClient.authtoken}"
       payload =  self.construct_payload( work )
       status, response = self.rest_send( url, :post, payload )

       return status, response['details']['id'] if EntityIdClient.ok?( status ) && response['details'] && response['details']['id']
       return status, ''
     end

     #
     # update an existing DOI with any metadata we can determine from the supplied work
     #
     def self.metadatasync( work )
       url = "#{EntityIdClient.url}/#{work.identifier[ 0 ]}?auth=#{EntityIdClient.authtoken}"
       payload =  self.construct_payload( work )
       status, response = self.rest_send( url, :put, payload )
       return status
     end

     #
     # remove a DOI entry
     #
     def self.remove( work )
       # not implemented
       500
     end

     private

     #
     # construct the request payload
     #
     def self.construct_payload( work )
       h = {}
       h['title'] = work.title[ 0 ] if work.title[ 0 ]
       h['publisher'] = 'the publisher'
       h['creator'] = work.creator[ 0 ] if work.creator[ 0 ]
       h['url'] = 'http://example.com/blablabla'
       h['publication_year'] = '2016'
       h['type'] = 'Dataset'
       h.to_json
     end

     #
     # configuration helpers
     #

     def self.shoulder
       ServiceClient.configuration[ :shoulder ]
     end

     def self.authtoken
       ServiceClient.configuration[ :authtoken ]
     end

     def self.url
       ServiceClient.configuration[ :url ]
     end

   end
end
