class APIV1DownloadsController < APIBaseController

  #
  # get content
  #
  def get_content
    fileset = get_the_fileset
    if fileset.nil? == false
       filename = "#{CurationConcerns.config.working_path}/#{source_name_from_fileset( fileset )}"
#       puts "==> content #{filename}"
       if File.exist?( filename )
          mimetype = MIME::Types.type_for( filename ).first.content_type
          send_file filename, :type => mimetype, :disposition => "attachment; filename=#{destination_name_from_fileset( fileset )}"
       else
          render_nothing
       end
    else
       render_nothing
    end

  end

  #
  # get thumbnail
  #
  # thumbnails are generated and are always jpeg files. They are downloaded inline
  #
  def get_thumbnail
    fileset = get_the_fileset
    if fileset.nil? == false
       filename = "#{CurationConcerns.config.derivatives_path}/#{thumbnail_from_fileset( fileset )}"
#       puts "==> thumbnail #{filename}"
       if File.exist?( filename )
          send_file filename, :type => 'image/jpeg', :disposition => 'inline'
       else
          render_nothing
       end
    else
       render_nothing
    end

  end

  private

  def render_nothing
    render :nothing => true, :type => 'text/plain', :status => :not_found
  end

  def source_name_from_fileset( fileset )
    return "#{dirname_from_fileset( fileset )}/#{fileset.label}"
  end

  def destination_name_from_fileset( fileset )
    return "#{fileset.title[ 0 ]}"
  end

  def thumbnail_from_fileset( fileset )
    id = fileset.id
    return "#{dirname_from_fileset( id )}/#{id[8]}-thumbnail.jpeg"
  end

  def dirname_from_fileset( fileset )
    id = fileset.id
    return "#{id[0]}#{id[1]}/#{id[2]}#{id[3]}/#{id[4]}#{id[5]}/#{id[6]}#{id[7]}"
  end

end


