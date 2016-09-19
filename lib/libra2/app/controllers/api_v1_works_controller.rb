class APIV1WorksController < APIBaseController

  before_action :validate_user, only: [ :delete_work,
                                        :update_work
                                      ]

  #
  # get all works
  #
  def all_works
    start = numeric( params[:start], DEFAULT_START )
    limit = numeric( params[:limit], DEFAULT_LIMIT )

    works = batched_get( {}, start, limit )
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

    work_search = API::WorkSearch.new.from_json( params )
    if work_search.valid_for_search?

       works = do_works_search( work_search )
       if works.empty?
         render_works_response( :not_found )
       else
         render_works_response( :ok, work_transform( works ) )
       end
    else
      render_works_response( :bad_request, nil, 'Missing or incorrect parameter' )
    end

  end

  #
  # get a specific work details
  #
  def get_work
    works = batched_get( { id: params[:id] }, 0, 1 )
    if works.empty?
      render_works_response( :not_found )
    else
      render_works_response( :ok, work_transform( works ) )
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
  # update a work
  #
  def update_work
    work = get_the_work
    if work.nil?
      render_standard_response( :not_found )
    else

      work_update = API::Work.new.from_json( params_whitelist )
      if work_update.valid_for_update?

        apply_and_audit( work, work_update )

        # if this work published, send the metadata to the DOI service
        if work.is_draft? == false && must_resubmit_metadata( work_update )
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
    if field.present?
      return batched_get( { author_email: field }, start, limit )
    end

    field = search.create_date
    if field.present?
      return batched_get( "system_create_dtsi: #{search.make_solr_date_search( field )}", start, limit )
    end

    field = search.depositor_email
    if field.present?
      return batched_get( { depositor: field }, start, limit )
    end

    field = search.modified_date
    if field.present?
      return batched_get( "system_modified_dtsi: #{search.make_solr_date_search( field )}", start, limit )
    end

    field = search.status
    if field.present?
      if field == 'pending'
         draft = 'true'
      else
         draft = 'false'
      end
      return batched_get( { draft: draft }, start, limit )
    end

    return []
  end

  def apply_and_audit( work, work_update )

    if field_changed( :abstract, work_update, work.description, work_update.abstract )
      # update and audit the information
      audit_change(work, 'Abstract', work.description, work_update.abstract )
      work.description = work_update.abstract
    end
    if field_changed( :author_email, work_update, work.author_email, work_update.author_email )
      # update and audit the information
      audit_change(work, 'Author Email', work.author_email, work_update.author_email )
      work.author_email = work_update.author_email
    end
    if field_changed( :author_first_name, work_update, work.author_first_name, work_update.author_first_name )
      # update and audit the information
      audit_change(work, 'Author First Name', work.author_first_name, work_update.author_first_name )
      work.author_first_name = work_update.author_first_name
    end
    if field_changed( :author_last_name, work_update, work.author_last_name, work_update.author_last_name )
      # update and audit the information
      audit_change(work, 'Author Last Name', work.author_last_name, work_update.author_last_name )
      work.author_last_name = work_update.author_last_name
    end
    if field_changed( :author_institution, work_update, work.author_institution, work_update.author_institution )
      # update and audit the information
      audit_change(work, 'Author Institution', work.author_institution, work_update.author_institution )
      work.author_institution = work_update.author_institution
    end
    if field_changed( :author_department, work_update, work.department, work_update.author_department )
      # update and audit the information
      audit_change(work, 'Department', work.department, work_update.author_department )
      work.department = work_update.author_department
    end
    if field_changed( :depositor_email, work_update, work.depositor, work_update.depositor_email )
      # update and audit the information
      audit_change(work, 'Depositor Email', work.depositor, work_update.depositor_email )

      work.edit_users -= [ work.depositor ]
      work.edit_users += [ work_update.depositor_email ]
      work.depositor = work_update.depositor_email
    end
    if field_changed( :degree, work_update, work.degree, work_update.degree )
      # update and audit the information
      audit_change(work, 'Degree', work.degree, work_update.degree )
      work.degree = work_update.degree
    end
    if field_changed( :embargo_state, work_update, work.embargo_state, work_update.embargo_state )
      # update and audit the information
      audit_change(work, 'Embargo Type', work.embargo_state, work_update.embargo_state )
      work.embargo_state = work_update.embargo_state
    end

    # special case where date formats are converted
    if work_update.field_set?( :embargo_end_date )
      new_end_date = work_update.convert_date( work_update.embargo_end_date )
      if new_end_date.to_s != work.embargo_end_date
         # update and audit the information
         audit_change(work, 'Embargo End Date', work.embargo_end_date, new_end_date.to_s )
         work.embargo_end_date = new_end_date
      end
    end
    if field_changed( :notes, work_update, work.notes, work_update.notes )
      # update and audit the information
      audit_change(work, 'Notes', work.notes, work_update.notes )
      work.notes = work_update.notes
    end
    # special case, we always *add* to an existing set of notes
    if work_update.field_set?( :admin_notes ) && work_update.admin_notes.blank? == false
      # update and audit the information
      audit_add(work, 'Admin Notes', work_update.admin_notes )
      work.admin_notes = work.admin_notes.concat( work_update.admin_notes )
    end
    if field_changed( :rights, work_update, work.rights, [ work_update.rights ] )
      # update and audit the information
      audit_change(work, 'Rights', work.rights, [ work_update.rights ] )
      work.rights = [ work_update.rights ]
    end
    if field_changed( :title, work_update, work.title, [ work_update.title ] )
      # update and audit the information
      audit_change(work, 'Title', work.title, [ work_update.title ] )
      work.title = [ work_update.title ]
    end
    if field_changed( :advisers, work_update, work.contributor, work_update.advisers )
      # update and audit the information
      audit_change(work, 'Advisers', work.contributor, work_update.advisers )
      work.contributor = work_update.advisers
    end
    if field_changed( :keywords, work_update, work.keyword, work_update.keywords )
      # update and audit the information
      audit_change(work, 'Keywords', work.keyword, work_update.keywords )
      work.keyword = work_update.keywords
    end
    if field_changed( :language, work_update, work.language, work_update.language )
      # update and audit the information
      audit_change(work, 'Language', work.language, work_update.language )
      work.language = work_update.language
    end
    if field_changed( :related_links, work_update, work.related_url, work_update.related_links )
      # update and audit the information
      audit_change(work, 'Related Links', work.related_url, work_update.related_links )
      work.related_url = work_update.related_links
    end
    if field_changed( :sponsoring_agency, work_update, work.sponsoring_agency, work_update.sponsoring_agency )
      # update and audit the information
      audit_change(work, 'Sponsoring Agency', work.sponsoring_agency, work_update.sponsoring_agency )
      work.sponsoring_agency = work_update.sponsoring_agency
    end
    if field_changed( :published_date, work_update, work.date_published, work_update.published_date )
      # update and audit the information
      audit_change(work, 'Publication Date', work.date_published, work_update.published_date )
      work.date_published = work_update.published_date
    end

    # actually update the work
    work.date_modified = DateTime.now
    work.save!
  end

  #
  # resubmit the metadata if any of the fields that are included have changed
  #
  def must_resubmit_metadata( work_update )
    return true if work_update.field_set?( :author_email )
    return true if work_update.field_set?( :author_first_name )
    return true if work_update.field_set?( :author_last_name )
    return true if work_update.field_set?( :author_department )
    return true if work_update.field_set?( :author_institution )
    return true if work_update.field_set?( :title )
    return true if work_update.field_set?( :degree )
    return true if work_update.field_set?( :published_date )
    return false
  end

  def field_changed( field, update, before, after )

     # if we did not set the field then it has not changed
     return false if update.field_set?( field ) == false

     # if they are the same, then it has not changed
     return false if after == before

     #puts "==> #{field} has changed"
     return true
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
            fs = API::Fileset.new.from_solr( fsid, "#{request.base_url}/api/v1" )
            w.filesets << fs
          end
          tstart = Time.now
        end

      end
      res << w
    end
    return res
  end

  def render_works_response( status, works = [], message = nil )
    render json: API::WorkListResponse.new( status, works, message ), :status => status
  end

  def find_fileset( work, fsid )
    return nil if fsid.nil?
    return nil if work.file_sets.nil?
    work.file_sets.each { |fs | return fs if fs.id == fsid }
    return nil
  end

  def batched_get( constraints, start_ix, end_ix )

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
                                  :title,
                                  :admin_notes => [],
                                  :advisers => [],
                                  :keywords => [],
                                  :related_links => [],
                                  :sponsoring_agency => []
                                )
  end

  def audit_change(work, what, old_value, new_value )
    audit_log( "#{what} for work id #{work.id} (#{work.identifier}) changed from '#{old_value}' to '#{new_value}' by #{User.cid_from_email( @api_user.email)}" )
  end

  def audit_add(work, what, new_value )
    audit_log( "#{what} for work id #{work.id} (#{work.identifier}) updated to include '#{new_value}' by #{User.cid_from_email( @api_user.email)}" )
  end

end

