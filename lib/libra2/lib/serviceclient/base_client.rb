require 'rest_client'

module ServiceClient

   class BaseClient

     def configuration
       @configuration
     end

     #
     # basic helper
     #
     def ok?( status )
       return( status == 200 || status == 201 )
     end

     #
     # send the supplied payload to the supplied endpoint using the supplied HTTP method (:put, :post)
     #
     def rest_send( url, method, payload )
       begin
         response = RestClient::Request.execute( method: method,
                                                 url: URI.escape( url ),
                                                 payload: payload,
                                                 content_type: :json,
                                                 accept: :json,
                                                 timeout: self.timeout )

         if ok?( response.code ) && response.empty? == false && response != ' '
           return response.code, JSON.parse( response )
         end
         return response.code, {}
       rescue RestClient::ResourceNotFound => e
         return e.http_code, {}
       rescue RestClient::Exception => e
         puts "POST, URL: #{url}" if method == :post
         puts "PUT, URL: #{url}" if method == :put
         puts "Payload: #{payload}"
         puts e
         return e.http_code, {}
       rescue SocketError => e
         puts "POST, URL: #{url}" if method == :post
         puts "PUT, URL: #{url}" if method == :put
         puts e
         return 500, {}
       end
     end

     def rest_get( url )
       begin
         response = RestClient::Request.execute( method: :get,
                                                 url: URI.escape( url ),
                                                 accept: :json,
                                                 timeout: self.timeout )

         if ok?( response.code ) && response.empty? == false && response != ' '
           return response.code, JSON.parse( response )
         end
         return response.code, {}
       rescue RestClient::ResourceNotFound => e
         return e.http_code, {}
       rescue RestClient::Exception => e
         puts "GET, URL: #{url}"
         puts e
         return e.http_code, {}
       rescue SocketError => e
         puts "GET, URL: #{url}"
         puts e
         return 500, {}
       end
     end

     #
     # load the supplied configuration file
     #
     def load_config( filename )

       fullname = "#{Rails.application.root}/lib/libra2/config/#{filename}"
       begin
         config_erb = ERB.new( IO.read( fullname ) ).result( binding )
       rescue StandardError => e
         raise( "#{filename} could not be parsed with ERB. \n#{e.inspect}" )
       end

       begin
         yml = YAML.load( config_erb )
       rescue Psych::SyntaxError => e
         raise "#{filename} could not be parsed as YAML. \nError #{e.message}"
       end

       config = yml.symbolize_keys
       @configuration = config[ Rails.env.to_sym ].symbolize_keys || {}
     end

     #
     # configuration helper
     #
     def timeout
       configuration[ :timeout ]
     end

   end

end
