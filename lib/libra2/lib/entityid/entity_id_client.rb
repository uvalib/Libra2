require 'rest_client'

module Libra2
   class EntityIdClient

     class << self
        attr_accessor :configuration
     end

     def self.configuration
       @configuration ||= EntityIdClient.load_config
     end

     def self.newid( work )
       url = "#{EntityIdClient.url}/#{EntityIdClient.shoulder}?auth=#{EntityIdClient.authtoken}"
       payload =  self.payload( work )
       status, response = self.send( url, :post, payload )

       return status, response['details']['id'] if EntityIdClient.ok?( status ) && response['details'] && response['details']['id']
       return status, ''
     end

     def self.metadatasync( work )
       url = "#{EntityIdClient.url}/#{work.identifier[ 0 ]}?auth=#{EntityIdClient.authtoken}"
       payload =  self.payload( work )
       status, response = self.send( url, :put, payload )
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

     def self.send( url, method, payload )
       begin
         response = RestClient::Request.execute( method: method,
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
       EntityIdClient.configuration[ :shoulder ]
     end

     def self.authtoken
       EntityIdClient.configuration[ :authtoken ]
     end

     def self.url
       EntityIdClient.configuration[ :url ]
     end

     def self.timeout
       EntityIdClient.configuration[ :timeout ]
     end

     def self.load_config

       filename = "entityid.yml"
       fullname = "#{Rails.application.root}/lib/libra2/config/#{filename}"
       begin
         config_erb = ERB.new( IO.read( fullname ) ).result( binding )
       rescue StandardError
         raise( "#{filename} was found, but could not be parsed with ERB. \n#{$ERROR_INFO.inspect}" )
       end

       begin
         yml = YAML.load( config_erb )
       rescue Psych::SyntaxError => e
         raise "#{filename} was found, but could not be parsed. \nError #{e.message}"
       end

       config = yml.symbolize_keys
       @configuration = config[ Rails.env.to_sym ].symbolize_keys || {}
     end

   end
end
