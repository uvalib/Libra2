module StatisticsHelper

  #
  # record a work view event
  #
  def record_work_view_event( id, user = nil )
    puts "==> work view event: work id #{id}"
    event = find_todays_existing_view_event( id, user )
    if event.nil? == false
      event.work_views += 1
    else
      event = create_new_view_event( id, user )
    end
    save_safely( event )
  end

  #
  # record a file download event
  #
  def record_file_download_event( id, user = nil )
    puts "==> file download event: file id #{id}"
    event = find_todays_existing_download_event( id, user )
    if event.nil? == false
       event.downloads += 1
    else
       event = create_new_download_event( id, user )
    end
    save_safely( event )
  end

  #
  # get an aggregate count of work views
  #
  def get_work_view_count( work )
    return WorkViewStat.where( 'work_id = ?', work.id ).sum( :work_views )
  end

  #
  # get an aggregate count of work downloads
  #
  def get_work_download_count( work )
    return 0 if work.filesets.blank?
    sum = 0
    work.filesets.each { |fs|
      sum += get_file_download_count( fs.id )
    }
    return sum
  end

  #
  # get an aggregate size of the work files
  #
  def get_work_aggregate_size( work )
    return 0 if work.filesets.blank?
    sum = 0
    work.filesets.each { |fs|
      sum += fs.file_size
    }
    return sum
  end

  #
  # get an aggregate count of file downloads
  #
  def get_file_download_count( fileset_id )
    return FileDownloadStat.where( 'file_id = ?', fileset_id ).sum( :downloads )
  end

  #
  # get a list of view events that are identified by user
  #
  def get_all_identified_view_events
     WorkViewStat.where( 'user_id is not NULL' )
  end

  #
  # get a list of download events that are identified by user
  #
  def get_all_identified_download_events
     FileDownloadStat.where( 'user_id is not NULL' )
  end

  #
  # anonymize the supplied view event
  #
  def anonymize_work_view_event( view_event )

    # find an anomomyzed version
    event = find_existing_view_event( view_event.date, view_event.work_id, nil )
    if event.nil? == false
       event.work_views += view_event.work_views
    else
       event = create_new_view_event( view_event.work_id, nil )
       event.date = view_event.date
    end
    save_safely( event )

    view_event.destroy
  end

  #
  # anonymize the supplied download event
  #
  def anonymize_file_download_event( download_event )

    # find an anomomyzed version
    event = find_existing_download_event( download_event.date, download_event.file_id, nil )
    if event.nil? == false
       event.downloads += download_event.downloads
    else
       event = create_new_download_event( download_event.file_id, nil )
       event.date = download_event.date
    end
    save_safely( event )

    download_event.destroy
  end

  private

  def find_todays_existing_view_event( id, user )
     today = time_now.beginning_of_day
     return find_existing_view_event( today, id, user )
  end

  def find_todays_existing_download_event( id, user )
     today = time_now.beginning_of_day
     return find_existing_download_event( today, id, user )
  end

  def find_existing_view_event( date, id, user )
    if user.nil?
      res = WorkViewStat.where( 'date = ? AND work_id = ? AND user_id is NULL', date, id ).first
    else
      res = WorkViewStat.where( 'date = ? AND work_id = ? AND user_id = ?', date, id, user.id ).first
    end
    return res
  end

  def find_existing_download_event( date, id, user )
    if user.nil?
      res = FileDownloadStat.where( 'date = ? AND file_id = ? AND user_id is NULL', date, id ).first
    else
      res = FileDownloadStat.where( 'date = ? AND file_id = ? AND user_id = ?', date, id, user.id ).first
    end
    return res
  end

  def create_new_view_event( id, user )
    event = WorkViewStat.new
    event.date = time_now.beginning_of_day
    event.work_views = 1
    event.work_id = id
    event.user_id = user.id unless user.nil?
    return event
  end

  def create_new_download_event( id, user )
    event = FileDownloadStat.new
    event.date = time_now.beginning_of_day
    event.downloads = 1
    event.file_id = id
    event.user_id = user.id unless user.nil?
    return event
  end

  def time_now
    CurationConcerns::TimeService.time_in_utc
  end

  def save_safely( event )
    begin
      event.save!
    rescue => e
      puts "==> ERROR save_safely: #{e}"
    end
  end
end
