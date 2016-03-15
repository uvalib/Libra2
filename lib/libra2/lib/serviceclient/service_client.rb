require 'rest_client'

module Libra2

   class ServiceClient

     class << self
       attr_accessor :config_file
       attr_accessor :configuration
     end

     def self.config_file
       @config_file ||= "unknown.yml"
     end

     def self.configuration
       @configuration ||= ServiceClient.load_config( ServiceClient.config_file )
     end

     #
     # basic helper
     #
     def self.ok?( status )
       return( status == 200 || status == 201 )
     end

     private

     #
     # send the supplied payload to the supplied endpoint using the supplied HTTP method (:put, :post)
     #
     def self.rest_send( url, method, payload )
       begin
         response = RestClient::Request.execute( method: method,
                                                 url: URI.escape( url ),
                                                 payload: payload,
                                                 content_type: :json,
                                                 timeout: ServiceClient.timeout )

         if ServiceClient.ok?( response.code ) && response.empty? == false && response != ' '
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

     #
     # load the supplied configuration file
     #
     def self.load_config( filename )

       fullname = "#{Rails.application.root}/lib/libra2/config/#{filename}"
       begin
         config_erb = ERB.new( IO.read( fullname ) ).result( binding )
       rescue StandardError
         raise( "#{filename} was found, but could not be parsed with ERB. \n#{$ERROR_INFO.inspect}" )
       end

       begin
         yml = YAML.load( config_erb )
       rescue Psych::SyntaxError => e
         raise "#{filename} was found, but could not be parsed as YAML. \nError #{e.message}"
       end

       config = yml.symbolize_keys
       @configuration = config[ Rails.env.to_sym ].symbolize_keys || {}
     end

     #
     # configuration helper
     #
     def self.timeout
       ServiceClient.configuration[ :timeout ]
     end

   end

end
