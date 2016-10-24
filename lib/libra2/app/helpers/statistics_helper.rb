module StatisticsHelper

  #
  # record a work view event
  #
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

  #
  # record a file download event
  #
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
      sum += get_file_download_count( fs )
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
  def get_file_download_count( fileset )
    return FileDownloadStat.where( 'file_id = ?', fileset.id ).sum( :downloads )
  end

  private

  def find_existing_view_event( id, user )
    today = time_now.beginning_of_day
    if user.nil?
      res = WorkViewStat.where( 'date = ? AND work_id = ? AND user_id is NULL', today, id ).first
    else
      res = WorkViewStat.where( 'date = ? AND work_id = ? AND user_id = ?', today, id, user.id ).first
    end
    return res
  end

  def find_existing_download_event( id, user )
    today = time_now.beginning_of_day
    if user.nil?
      res = FileDownloadStat.where( 'date = ? AND file_id = ? AND user_id is NULL', today, id ).first
    else
      res = FileDownloadStat.where( 'date = ? AND file_id = ? AND user_id = ?', today, id, user.id ).first
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
