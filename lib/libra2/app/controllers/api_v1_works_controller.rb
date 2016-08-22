class APIV1WorksController < APIBaseController

  before_action :validate_user, only: [ :delete_work,
                                        :update_work_title,
                                        :update_work_embargo,
                                        :add_work_fileset,
                                        :remove_work_fileset
                                      ]

  @default_limit = 100

  #
  # get all works
  #
  def all_works
    limit = params[:limit] || @default_limit
    works = GenericWork.all.limit( limit )
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
      # audit the information
      audit_log( "Work id #{work.id} (#{work.identifier}) deleted by by #{User.cid_from_email( @api_user.email)}" )

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

        # audit the information
        audit_log( "Title of work id #{work.id} (#{work.identifier}) changed from #{work.title} to #{title} by #{User.cid_from_email( @api_user.email)}" )

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

  #
  # update the work embargo
  #
  def update_work_embargo
    work = get_the_work
    if work.nil?
      render_standard_response( :not_found )
    else
       render_standard_response( :bad_request, 'Not implemented' )
    end
  end

  #
  # add a file to the specified work
  #
  def add_work_fileset
    work = get_the_work
    if work.nil?
      render_standard_response( :not_found )
    else
      render_standard_response( :bad_request, 'Not implemented' )
    end
  end

  def remove_work_fileset
    work = get_the_work
    if work.nil?
      render_standard_response( :not_found )
    else

      fileset = find_fileset( work, params[:fsid] )
      if fileset.nil?
        render_standard_response( :not_found, 'Fileset not available' )
      else
        # audit the information
        audit_log( "File #{fileset.title[0]} for work id #{work.id} (#{work.identifier}) deleted by #{User.cid_from_email( @api_user.email)}" )

        file_actor = ::CurationConcerns::Actors::FileSetActor.new( fileset, @api_user )
        file_actor.destroy
        render_standard_response( :ok )
      end

    end
  end

  private

  def do_works_search

    limit = params[:limit] || @default_limit

    field = params[:status]
    if field.present?
      if field == 'pending'
         draft = 'true'
      else
         draft = 'false'
      end
      return GenericWork.where( { draft: draft } ).limit( limit )
    end

    field = params[:author_email]
    if field.present?
      return GenericWork.where( { author_email: field } ).limit( limit )
    end

    field = params[:create_date]
    if field.present?
      return GenericWork.where( { date_created: field.gsub( '-', '/' ) } ).limit( limit )
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

  def render_works_response( status, works = [] )
    render json: API::WorkListResponse.new( status, works ), :status => status
  end

  def find_fileset( work, fsid )
    return nil if fsid.nil?
    return nil if work.file_sets.nil?
    work.file_sets.each { |fs | return fs if fs.id == fsid }
    return nil
  end
end

