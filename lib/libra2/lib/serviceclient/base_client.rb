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
       rescue RestClient::BadRequest => ex
         log_error( method, url, nil, payload )
         return 400, {}
       rescue RestClient::ResourceNotFound => ex
         log_error( method, url, nil, payload )
         return 404, {}
       rescue RestClient::RequestTimeout => ex
         log_error( method, url, nil, payload )
         puts "ERROR: request timeout: #{url} (#{self.timeout} seconds)"
         return 408, {}
       rescue RestClient::Exception, SocketError, Exception => ex
         log_error( method, url, ex, payload )
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
       rescue RestClient::BadRequest => ex
         log_error( :get, url )
         return 400, {}
       rescue RestClient::ResourceNotFound => ex
         log_error( :get, url )
         return 404, {}
       rescue RestClient::RequestTimeout => ex
         puts "ERROR: request timeout: #{url} (#{self.timeout} seconds)"
         log_error( :get, url )
         return 408, {}
       rescue RestClient::Exception, SocketError, Exception => ex
         log_error( :get, url, ex )
         return 500, {}
       end
     end

     def rest_delete( url )
       begin
         response = RestClient::Request.execute( method: :delete,
                                                 url: URI.escape( url ),
                                                 timeout: self.timeout )

         return response.code
       rescue RestClient::BadRequest => ex
         log_error( :delete, url )
         return 400
       rescue RestClient::ResourceNotFound => ex
         log_error( :delete, url )
         return 404
       rescue RestClient::RequestTimeout => ex
         puts "ERROR: request timeout: #{url} (#{self.timeout} seconds)"
         log_error( :delete, url )
         return 408
       rescue RestClient::Exception, SocketError, Exception => ex
         log_error( :delete, url, ex )
         return 500
       end
     end

     #
     # load the supplied configuration file
     #
     def load_config( filename )

       fullname = "#{Rails.application.root}/lib/libra2/config/#{filename}"
       begin
         config_erb = ERB.new( IO.read( fullname ) ).result( binding )
       rescue StandardError => ex
         raise( "#{filename} could not be parsed with ERB. \n#{ex.inspect}" )
       end

       begin
         yml = YAML.load( config_erb )
       rescue Psych::SyntaxError => ex
         raise "#{filename} could not be parsed as YAML. \nError #{ex.message}"
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

     #
     # error log helper
     #
     def log_error( method, url, ex = nil, payload = nil )

       verb = 'GET'
       verb = 'POST' if method == :post
       verb = 'PUT' if method == :put
       verb = 'DELETE' if method == :delete

       puts "#{verb} url: #{url}"
       puts "#{verb} payload: #{payload}" if payload.nil? == false
       puts "#{ex.class}: #{ex}" if ex.nil? == false

     end
   end

end
