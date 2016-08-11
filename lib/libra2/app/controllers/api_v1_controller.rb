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
      # actually do the delete
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
      # actually update the title
      status = :ok
      render json: API::BaseResponse.new( status ), :status => status
    end
  end

  private

  def work_transform( generic_works )
    return [] if generic_works.empty?
    return generic_works.map{ | gw | API::Work.new( gw ) }
  end
end
