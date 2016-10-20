module StatisticsHelper

  def work_view_event( id, user )
    puts "==> work view event: work id #{id}, user: #{user}"
    event = find_existing_view_event( id, user )
    if event.nil? == false
      event.work_views += 1
    else
      event = create_new_view_event( id, user )
    end
    save_safely( event )
  end

  def file_download_event( id, user )
    puts "==> file download event: file id #{id}, user: #{user}"
    event = find_existing_download_event( id, user )
    if event.nil? == false
       event.downloads += 1
    else
       event = create_new_download_event( id, user )
    end
    save_safely( event )
  end

  private

  def find_existing_view_event( id, user )
    today = formatted_yyyymmdd( time_now )
    if user.nil?
      res = WorkViewStat.where( 'date = ? AND work_id = ? AND user_id is NULL', today, id ).first
    else
      res = WorkViewStat.where( 'date = ? AND work_id = ? AND user_id = ?', today, id, user.id ).first
    end
    return res
  end

  def find_existing_download_event( id, user )
    today = formatted_yyyymmdd( time_now )
    if user.nil?
      res = FileDownloadStat.where( 'date = ? AND file_id = ? AND user_id is NULL', today, id ).first
    else
      res = FileDownloadStat.where( 'date = ? AND file_id = ? AND user_id = ?', today, id, user.id ).first
    end
    return res
  end

  def create_new_view_event( id, user )
    event = WorkViewStat.new
    event.date = formatted_yyyymmdd( time_now )
    event.work_views = 1
    event.work_id = id
    event.user_id = user.id unless user.nil?
    return event
  end

  def create_new_download_event( id, user )
    event = FileDownloadStat.new
    event.date = formatted_yyyymmdd( time_now )
    event.downloads = 1
    event.file_id = id
    event.user_id = user.id unless user.nil?
    return event
  end

  private

  def time_now
    CurationConcerns::TimeService.time_in_utc
  end

  def formatted_yyyymmdd( date )
     return date.strftime( "%Y-%m-%d 00:00:00" )
  end

  def save_safely( event )
    begin
      event.save!
    rescue => e
      puts "==> ERROR save_safely: #{e}"
    end
  end
end
