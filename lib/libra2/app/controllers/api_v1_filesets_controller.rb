require 'securerandom'

class APIV1FilesetsController < APIBaseController

  include UploadCacheBehavior
  include UrlHelper

  before_action :validate_user, only: [ :add_fileset,
                                        :remove_fileset
                                      ]

  #
  # get all filesets
  #
  def all_filesets

    start = numeric( params[:start], DEFAULT_START )
    limit = numeric( params[:limit], DEFAULT_LIMIT )
    filesets = batched_get( {}, start, limit )

    respond_to do |format|
      format.json do
         if filesets.empty?
            render_json_fileset_response(:not_found )
         else
            render_json_fileset_response(:ok, fileset_transform( filesets ) )
         end
      end
      format.csv do
        render_csv_fileset_response( fileset_transform( filesets ) )
      end
    end
  end

  #
  # get the specified fileset
  #
  def get_fileset

    filesets = batched_get( { id: params[:id] }, 0, 1 )
    if fileset.nil? == false
      render_json_fileset_response(:ok, fileset_transform( filesets ) )
    else
      render_json_fileset_response(:not_found )
    end
  end

  #
  # add a new file(set)
  #
  def add_fileset

    # grab the parameters
    work_id = params[:work]
    file_id = params[:file]
    label = params[:label]

    # validate them
    if work_id.blank? == false && file_id.blank? == false && label.blank? == false
       work = get_the_work( work_id )
       if work.nil? == false
         filename = APIV1FilesetsController.cache_contents( file_id )
         if filename.blank? == false
            fileset = ::FileSet.new
            fileset.title << label
            file_actor = ::CurationConcerns::Actors::FileSetActor.new( fileset, @api_user )
            file_actor.create_metadata( work )
            file_actor.create_content( File.open( filename ) )
            fileset.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
            fileset.save!

            # audit the information
            #audit_log( "File #{label} for work id #{work_id} (#{work.identifier}) added by #{User.cid_from_email( @api_user.email)}" )
            WorkAudit.audit( work_id, User.cid_from_email( @api_user.email), "File #{label} added" )

            render_standard_response( :ok )
         else
            render_standard_response( :not_found, 'File not found' )
         end
       else
          render_standard_response( :not_found, 'Work not found' )
       end
    else
      render_standard_response( :unauthorized, 'Missing work identifier or file identifier or file label' )
    end

  end

  #
  # remove the specified fileset
  #
  def remove_fileset

    fileset = get_the_fileset
    if fileset.nil? == false
      works = fileset.in_works
      work_id = works.empty? ? 'unknown' : works[0].id

      # audit the information
      WorkAudit.audit( work_id, User.cid_from_email( @api_user.email), "File #{fileset.title[0]} deleted" )

      file_actor = ::CurationConcerns::Actors::FileSetActor.new( fileset, @api_user )
      file_actor.destroy
      render_standard_response( :ok )
    else
      render_standard_response( :not_found, 'Fileset not available' )
    end

  end

  private

  #
  # render a json response
  #
  def render_json_fileset_response( status, filesets = nil )
    render json: API::FilesetListResponse.new( status, filesets ), :status => status
  end

  #
  # render a csv response
  #
  def render_csv_fileset_response( filesets )
    @records = filesets
    headers['Content-Disposition'] = 'attachment; filename="fileset-list.csv"'
    headers['Content-Type'] ||= 'text/csv'
    render 'csv/v1/filesets'
  end

  def fileset_transform( solr_filesets )
    return [] if solr_filesets.empty?
    return solr_filesets.map { | fs | API::Fileset.new.from_solr( fs, "#{public_site_url}/api/v1" ) }
  end

  def batched_get( constraints, start_ix, end_ix )

    res = []
    count = end_ix - start_ix
    tstart = Time.now
    FileSet.search_in_batches( constraints, {:rows => count} ) do |group|
      elapsed = Time.now - tstart
      puts "===> extracted #{group.length} filesets(s) in #{elapsed}"
      #group.each { |r| puts "#{r.class}" }
      res.push( *group )
      tstart = Time.now
    end
    return res
  end

end


