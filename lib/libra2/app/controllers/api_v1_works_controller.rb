class APIV1WorksController < APIBaseController

  before_action :validate_user, only: [ :delete_work,
                                        :update_work_title,
                                        :update_work_embargo ]

  #
  # get all works
  #
  def all_works
    works = GenericWork.all
    if works.empty?
       render_works_response( :not_found )
    else
       render_works_response( :ok, work_transform( works ) )
    end
  end

  #
  # search works
  #
  def search_works
    works = do_works_search
    if works.empty?
      render_works_response( :not_found )
    else
      render_works_response( :ok, work_transform( works ) )
    end
  end

  #
  # get a specific work details
  #
  def get_work
    work = get_the_work
    if work.nil?
      render_works_response( :not_found )
    else
      render_works_response( :ok, work_transform( [ work ] ) )
    end
  end

  #
  # delete a work
  #
  def delete_work
    work = get_the_work
    if work.nil?
      render_standard_response( :not_found )
    else
      user = params[:user]  # already validated by the before_action

      # audit the information
      audit_log( "Work id #{work.id} (#{work.identifier}) deleted by by #{user}" )

      # actually do the delete
      work.destroy
      render_standard_response( :ok )
    end
  end

  #
  # update a work title
  #
  def update_work_title
    work = get_the_work
    if work.nil?
      render_standard_response( :not_found )
    else

      title = params[:title]
      if title.blank? == false

        user = params[:user] # already validated by the before_action

        # audit the information
        audit_log( "Title of work id #{work.id} (#{work.identifier}) changed from #{work.title} to #{title} by #{user}" )

        # actually update the title
        work.title = [ title ]
        work.save!

        # if this work published, send the metadata to the DOI service
        if work.is_draft? == false
           update_doi_metadata( work )
        end

        render_standard_response( :ok )
      else
        render_standard_response( :bad_request, 'Missing title parameter' )
      end
    end
  end

  def update_work_embargo
    work = get_the_work
    if work.nil?
      render_standard_response( :not_found )
    else
       render_standard_response( :bad_request, 'Not implemented' )
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

  def render_standard_response( status, message = nil )
    render json: API::BaseResponse.new( status, message ), :status => status
  end

  def render_works_response( status, works = [] )
    render json: API::WorkListResponse.new( status, works ), :status => status
  end

end

