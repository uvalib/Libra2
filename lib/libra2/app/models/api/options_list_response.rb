module API

class OptionsListResponse < BaseResponse

  attr_accessor :options

  def initialize( status, options, message = nil )
    super( status, message )
    @options = options
  end

end

end