require 'rest_client'

module Libra2
   class EntityIdClient

     class << self
        attr_accessor :configuration
     end

     def self.configuration
       if @configuration.nil?
         @configuration = YAML.load_file( "#{Rails.application.root}/lib/libra2/config/entityid.yml" )
         @configuration = @configuration[ Rails.env ]
       end
       @configuration
     end

     def self.newid( work )
       url = "#{EntityIdClient.url}/#{EntityIdClient.shoulder}"
       payload =  self.payload( work )
       status, response = self.post( url, payload )

       return status, response['details']['id'] if EntityIdClient.ok?( status ) && response['details'] && response['details']['id']
       return status, ''
     end

     def self.metadatasync( work )
       url = "#{EntityIdClient.url}/#{work.identifier[ 0 ]}"
       payload =  self.payload( work )
       status, response = self.post( url, payload )
       return status
     end

     def self.remove( work )
       # not implemented
       500
     end

     def self.ok?( status )
       return( status == 200 )
     end

     private

     def self.post( url, payload )
       begin
         response = RestClient::Request.execute( method: :post,
                                      url: URI.escape( url ),
                                      payload: payload,
                                      content_type: :json,
                                      timeout: EntityIdClient.timeout )

         if EntityIdClient.ok?( response.code ) && response.empty? == false && response != ' '
           return response.code, JSON.parse( response )
         end
         return response.code, {}
       rescue => e
         puts "URL: #{url}"
         puts "Payload: #{payload}"
         puts e
         return 500, {}
       end
     end

     def self.payload( work )
       h = {}
       h['title'] = work.title[ 0 ] if work.title[ 0 ]
       h['publisher'] = 'the publisher'
       h['creator'] = work.creator[ 0 ] if work.creator[ 0 ]
       h['url'] = 'http://example.com/blablabla'
       h['publication_year'] = '2016'
       h['type'] = 'Dataset'
       h.to_json
     end

     def self.shoulder
       EntityIdClient.configuration[ 'shoulder' ]
     end

     def self.authtoken
       EntityIdClient.configuration[ 'authtoken' ]
     end

     def self.url
       EntityIdClient.configuration[ 'url' ]
     end

     def self.timeout
       EntityIdClient.configuration[ 'timeout' ]
     end
   end
end
