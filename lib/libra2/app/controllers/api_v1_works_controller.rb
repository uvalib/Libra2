class APIV1WorksController < APIBaseController

  include UrlHelper

  before_action :validate_user, only: [ :delete_work,
                                        :update_work
                                      ]

  #
  # get all works, supports json (default) and csv responses
  #
  def all_works
    start = numeric( params[:start], DEFAULT_START )
    limit = numeric( params[:limit], DEFAULT_LIMIT )

    works = batched_get( {}, start, limit )
    respond_to do |format|
      format.json do
         if works.empty?
            render_json_works_response(:not_found )
         else
            render_json_works_response(:ok, work_transform( works ) )
         end
      end
      format.csv do
        render_csv_works_response( work_transform( works ) )
      end
    end

  end

  #
  # search works, supports json (default) and csv responses
  #
  def search_works

    work_search = API::WorkSearch.new.from_json( params )
    if work_search.valid_for_search?

       works = do_works_search( work_search )
       respond_to do |format|
         format.json do
            if works.empty?
               render_json_works_response(:not_found )
            else
               render_json_works_response(:ok, work_transform( works ) )
            end
         end
         format.csv do
           render_csv_works_response( work_transform( works ) )
         end
       end
    else
      render_json_works_response(:bad_request, nil, 'Missing or incorrect parameter' )
    end

  end

  #
  # get a specific work details
  #
  def get_work
    works = batched_get( { id: params[:id] }, 0, 1 )
    if works.empty?
      render_json_works_response(:not_found )
    else
      render_json_works_response(:ok, work_transform(works ) )
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
      #audit_log( "Work id #{work.id} (#{work.identifier}) deleted by by #{User.cid_from_email( @api_user.email)}" )
      WorkAudit.audit( work.id, User.cid_from_email( @api_user.email), 'Deleted' )

      # if the work is draft, we can remove the DOI, otherwise, we must revoke it
      if work.is_draft? == true
        remove_doi( work )
      else
        revoke_doi( work )
      end

      # actually do the delete
      work.destroy
      render_standard_response( :ok )
    end
  end

  #
  # update a work
  #
  def update_work
    work = get_the_work
    if work.nil?
      render_standard_response( :not_found )
    else

      work_update = API::Work.new.from_json( params_whitelist )
      if work_update.valid_for_update? == true

        # apply the update and save the work
        work_update.apply_to_work( work, User.cid_from_email( @api_user.email) )
        work.save!

        # if this work published, send the metadata to the DOI service
        if work.is_draft? == false && work_update.resubmit_metadata? == true
          update_doi_metadata( work )
        end

        render_standard_response( :ok )

      else
        render_standard_response( :bad_request, 'Missing or incorrect parameter' )
      end

    end
  end

  private

  def do_works_search( search )

    start = numeric( params[:start], DEFAULT_START )
    limit = numeric( params[:limit], DEFAULT_LIMIT )

    field = search.author_email
    if search.field_set?( :author_email )
      return batched_get( { author_email: field }, start, limit )
    end

    field = search.create_date
    if search.field_set?( :create_date )
      return batched_get( "system_create_dtsi:#{search.make_solr_date_search( field )}", start, limit )
    end

    field = search.depositor_email
    if search.field_set?( :depositor_email )
      return batched_get( { depositor: field }, start, limit )
    end

    field = search.modified_date
    if search.field_set?( :modified_date )
      return batched_get( "system_modified_dtsi:#{search.make_solr_date_search( field )}", start, limit )
    end

    field = search.status
    if search.field_set?( :status )
      if field == 'pending'
         draft = 'true'
      else
         draft = 'false'
      end
      return batched_get( { draft: draft }, start, limit )
    end

    field = search.work_source
    if search.field_set?( :work_source )
      return batched_get( "work_source_tesim:\"#{field}*\"", start, limit )
    end

    return []
  end

  def work_transform( solr_works )
    return [] if solr_works.empty?
    res = []
    solr_works.each do |solr|

      # make an API work record
      w = API::Work.new.from_solr( solr )

      filesets = w.filesets
      w.filesets = []
      # add the fileset information if necessary
      if filesets.empty? == false
        tstart = Time.now
        FileSet.search_in_batches( { id: filesets } ) do |fsg|
          elapsed = Time.now - tstart
          puts "===> extracted #{fsg.length} fileset(s) in #{elapsed}"
          fsg.each do |fsid|
            fs = API::Fileset.new.from_solr( fsid, "#{public_site_url}/api/v1" )
            w.filesets << fs
          end
          tstart = Time.now
        end

      end
      res << w
    end
    return res
  end

  #
  # render a json response
  #
  def render_json_works_response( status, works = [], message = nil )
    render json: API::WorkListResponse.new( status, works, message ), :status => status
  end

  #
  # render a csv response
  #
  def render_csv_works_response( works )
    @records = works
    headers['Content-Disposition'] = 'attachment; filename="work-list.csv"'
    headers['Content-Type'] ||= 'text/csv'
    render 'csv/v1/works'
  end

  def find_fileset( work, fsid )
    return nil if fsid.nil?
    return nil if work.file_sets.nil?
    work.file_sets.each { |fs | return fs if fs.id == fsid }
    return nil
  end

  def batched_get( constraints, start_ix, end_ix )

    puts "===> query: #{constraints}"
    res = []
    count = end_ix - start_ix
    tstart = Time.now
    GenericWork.search_in_batches( constraints, {:rows => count} ) do |group|
      elapsed = Time.now - tstart
      puts "===> extracted #{group.length} work(s) in #{elapsed}"
      #group.each { |r| puts "#{r.class}" }
      res.push( *group )
      tstart = Time.now
    end
    puts "===> returning #{res.length} work(s)"
    return res
  end

  def params_whitelist
    params.require(:work).permit( :abstract,
                                  :author_email,
                                  :author_first_name,
                                  :author_last_name,
                                  :author_department,
                                  :author_institution,
                                  :degree,
                                  :depositor_email,
                                  :embargo_state,
                                  :embargo_end_date,
                                  :language,
                                  :notes,
                                  :published_date,
                                  :rights,
                                  :status,
                                  :title,
                                  :admin_notes => [],
                                  :advisors => [],
                                  :keywords => [],
                                  :related_links => [],
                                  :sponsoring_agency => []
                                )
  end

end

