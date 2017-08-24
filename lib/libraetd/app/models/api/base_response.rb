module API

class BaseResponse

  attr_accessor :status
  attr_accessor :message

  def initialize( status, message = nil )
    @status = Rack::Utils.status_code( status )
    @message = Rack::Utils::HTTP_STATUS_CODES[ @status ]
    @message += " (#{message})" if message.blank? == false
  end

end

end