class APIV1FilesetsController < APIBaseController

  before_action :validate_user, only: [ :add_fileset,
                                        :remove_fileset
                                      ]

  #
  # get the specified fileset
  #
  def get_fileset
    fileset = get_the_fileset
    if fileset.nil? == false
      render_fileset_response( :ok, API::Fileset.new.from_fileset( fileset, "#{request.base_url}/api/v1" ) )
    else
      render_fileset_response( :not_found )
    end
  end

  #
  # add a new file(set)
  #
  def add_fileset
    work = get_the_work
    if work.nil?
      render_standard_response( :not_found )
    else
      render_standard_response( :bad_request, 'Not implemented' )
    end
  end

  #
  # remove the specified fileset
  #
  def remove_fileset

    fileset = get_the_fileset
    if fileset.nil? == false
      render_standard_response( :not_found, 'Fileset not available' )
    else
      # audit the information
    #  audit_log( "File #{fileset.title[0]} for work id #{work.id} (#{work.identifier}) deleted by #{User.cid_from_email( @api_user.email)}" )

    #  file_actor = ::CurationConcerns::Actors::FileSetActor.new( fileset, @api_user )
    #  file_actor.destroy
      render_standard_response( :ok )
    end

  end

  private

  def render_fileset_response( status, fileset = nil )
    render json: API::FilesetResponse.new( status, fileset ), :status => status
  end

end


