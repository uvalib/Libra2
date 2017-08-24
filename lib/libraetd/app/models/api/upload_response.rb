module API

class UploadResponse < BaseResponse

  attr_accessor :id

  def initialize( status, id, message = nil )
    super( status, message )
    @id = id
  end

end

end