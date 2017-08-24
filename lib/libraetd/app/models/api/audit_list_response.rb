module API

class AuditListResponse < BaseResponse

  attr_accessor :audits

  def initialize( status, audits, message = nil )
    super( status, message )
    @audits = audits
  end

end

end