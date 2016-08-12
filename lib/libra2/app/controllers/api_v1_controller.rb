class APIV1Controller < APIBaseController

  before_action :validate_user, only: [ :delete_work, :update_work_title ]

  #
  # get all works
  #
  def all_works
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
  # search works
  #
  def search_works
    works = do_works_search
    if works.empty?
      status = :not_found
      render json: API::WorkListResponse.new( status, [] ), :status => status
    else
      status = :ok
      render json: API::WorkListResponse.new( status, work_transform( works ) ), :status => status
    end

  end

  #
  # get a specific work details
  #
  def get_work
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
  # delete a work
  #
  def delete_work
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
  # update a work title
  #
  def update_work_title
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

  def do_works_search

    field = params[:state]
    if field.present?
      if field == 'pending'
         draft = 'true'
      else
         draft = 'false'
      end
      return GenericWork.where( { draft: draft } )
    end

    field = params[:author_email]
    if field.present?
      return GenericWork.where( { author_email: field } )
    end

    field = params[:create_date]
    if field.present?
      return GenericWork.where( { date_created: field.gsub( '-', '/' ) } )
    end

#    field = params[:modified_date]
#    if field.present?
#      return GenericWork.where( { date_modified: field } )
#      return GenericWork.where( date_modified: "[#{field}T00:00:00.000Z TO *]" )
#    end

    return []
  end

  def work_transform( generic_works )
    return [] if generic_works.empty?
    return generic_works.map{ | gw | API::Work.new( gw ) }
  end
end
