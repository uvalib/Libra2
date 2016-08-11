class APIV1Controller < APIBaseController

  before_action :validate_user, only: [ :delete, :update_title ]

  #
  # /api/v1/all
  #
  def all
    works = GenericWork.all
    if works.empty?
       status = :not_found
       render json: API::WorkListResponse.new( status, [] ), :status => status
    else
       status = :ok
       render json: API::WorkListResponse.new( status, work_transform( works ) ), :status => status
    end

  end

  #
  # /api/v1/search
  #
  def search
    works = GenericWork.all
    if works.empty?
      status = :not_found
      render json: API::WorkListResponse.new( status, [] ), :status => status
    else
      status = :ok
      render json: API::WorkListResponse.new( status, work_transform( works ) ), :status => status
    end

  end

  #
  # /api/v1/:id
  #
  def get
    work = get_the_work
    if work.nil?
      status = :not_found
      render json: API::WorkListResponse.new( status, [] ), :status => status
    else
      status = :ok
      render json: API::WorkListResponse.new( status, work_transform( [ work ] ) ), :status => status
    end

  end

  #
  # /api/v1/:id
  #
  def delete
    work = get_the_work
    if work.nil?
      status = :not_found
      render json: API::BaseResponse.new( status ), :status => status
    else
      user = params[:user]

      # audit the information
      audit_log( "Work id #{work.id} (#{work.identifier}) deleted by by #{user}" )

      # actually do the delete
      work.destroy
      status = :ok
      render json: API::BaseResponse.new( status ), :status => status
    end
  end

  #
  # /api/v1/:id/title/:title
  #
  def update_title
    work = get_the_work
    if work.nil?
      status = :not_found
      render json: API::BaseResponse.new( status ), :status => status
    else

      title = params[:title]
      user = params[:user]

      if title.blank? == false

        # audit the information
        audit_log( "Title of work id #{work.id} (#{work.identifier}) changed from #{work.title} to #{title} by #{user}" )

        # actually update the title
        work.title = [ title ]
        work.save!

        # if this work published, send the metadata to the DOI service
        if work.is_draft? == false
           update_doi_metadata( work )
        end

        status = :ok
        render json: API::BaseResponse.new( status ), :status => status
      else
        status = :bad_request
        render json: API::BaseResponse.new( status, 'Missing title parameter' ), :status => status
      end
    end
  end

  private

  def work_transform( generic_works )
    return [] if generic_works.empty?
    return generic_works.map{ | gw | API::Work.new( gw ) }
  end
end
