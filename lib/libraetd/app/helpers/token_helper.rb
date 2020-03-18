#
# helpers for validating inbound authorization tokens
#
module TokenHelper

  #
  # our shared secret for JWT validation
  #
  @@secret = nil

  #
  # validate the supplied token
  #
  def token_valid?( token )

    if @@secret.nil?
      @@secret = get_secret
    end

    begin
       JWT.decode token, @@secret, true, { algorithm: 'HS256' }
       return true
    rescue JWT::DecodeError
      puts "ERROR: decoding JWT or expired JWT"
    end
    return false

  end

  private

  #
  # load the secret from the configuration file
  #
  def self.get_secret
    cfg = load_config( "token.yml" )
    cfg[:secret]
  end

  #
  # load the supplied configuration file
  #
  def self.load_config( filename )

    fullname = "#{Rails.application.root}/lib/libraetd/config/#{filename}"
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
    return config[ Rails.env.to_sym ].symbolize_keys || {}
  end

end

#
# end of file
#
