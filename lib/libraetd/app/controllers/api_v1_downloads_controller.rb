class APIV1DownloadsController < APIBaseController

  #
  # get content
  #
  def get_content
    fileset = get_the_fileset
    if fileset.nil? == false
       file = fileset.original_file
       if file.nil? == false
          send_file_contents( file, fileset.title[ 0 ] )
       else
          puts "==> ERROR: cannot determine original file for fileset #{fileset.id}"
          render_nothing
       end
    else
       puts "==> ERROR: cannot locate fileset #{params[:id]}"
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
       if File.exist?( filename )
          send_file filename, :type => 'image/jpeg', :disposition => 'inline'
       else
          puts "==> ERROR: cannot locate thumbnail for fileset #{fileset.id} (#{filename})"
          render_nothing
       end
    else
       puts "==> ERROR: cannot locate fileset #{params[:id]}"
       render_nothing
    end

  end

  private

  def render_nothing
    render :nothing => true, :type => 'text/plain', :status => :not_found
  end

  def thumbnail_from_fileset( fileset )
    return "#{dirname_from_fileset( fileset )}/#{fileset.id[8]}-thumbnail.jpeg"
  end

  def dirname_from_fileset( fileset )
    id = fileset.id
    return "#{id[0]}#{id[1]}/#{id[2]}#{id[3]}/#{id[4]}#{id[5]}/#{id[6]}#{id[7]}"
  end

  #
  # shamelessly taken from Hydra::Controller::DownloadBehavior
  #

  def send_file_contents( file, filename )
    response.status = 200
    prepare_file_headers( file, filename )
    stream_body( file.stream )
  end

  def prepare_file_headers( file, filename )
    send_file_headers! content_options( file, filename )
    response.headers['Content-Type'] = file.mime_type
    response.headers['Content-Length'] ||= file.size.to_s
    response.content_type = file.mime_type
  end

  def stream_body(iostream)
    iostream.each do |in_buff|
      response.stream.write in_buff
    end
  ensure
    response.stream.close
  end

  def content_options( file, filename )
    { type: file.mime_type, filename: filename }
  end

end


