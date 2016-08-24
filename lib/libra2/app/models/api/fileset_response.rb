module API

class FilesetResponse < BaseResponse

  attr_accessor :fileset

  def initialize( status, fileset, message = nil )
    super( status, message )
    @fileset = fileset
  end

end

end