module API

class FilesetListResponse < BaseResponse

  attr_accessor :filesets

  def initialize( status, filesets, message = nil )
    super( status, message )
    @filesets = filesets
  end

end

end