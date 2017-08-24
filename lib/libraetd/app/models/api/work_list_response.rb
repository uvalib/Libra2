module API

class WorkListResponse < BaseResponse

  attr_accessor :works

  def initialize( status, works, message = nil )
    super( status, message )
    @works = works
  end

end

end