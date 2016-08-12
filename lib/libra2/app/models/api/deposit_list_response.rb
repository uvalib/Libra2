module API

class DepositListResponse < BaseResponse

  attr_accessor :deposits

  def initialize( status, deposits, message = nil )
    super( status, message )
    @deposits = deposits
  end

end

end