class APIV1FilesetsController < APIBaseController

  #
  # get the specified fileset
  #
  def get_fileset
    fileset = get_the_fileset
    if fileset.nil?
      render_fileset_response( :not_found )
    else
      render_fileset_response( :ok, API::Fileset.new.from_fileset( fileset ) )
    end
  end

  private

  def render_fileset_response( status, fileset = nil )
    render json: API::FilesetResponse.new( status, fileset ), :status => status
  end

end


