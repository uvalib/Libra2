require_dependency 'libra2/statistic'

class FileDownloadStat < Libra2::Statistic
  self.cache_column = :downloads
  self.event_type = :totalEvents

  def self.pw_statistics(start_date, file)
    puts "==> #{file.inspect}"
    Libra2::Analytics.downloads( { sort: 'date',
                                   start_date: date_to_yyyymmdd( start_date ),
                                   end_date: date_to_yyyymmdd( Date.yesterday ),
                                   file: file.id } )
  end

  def self.filter(file)
    { file_id: file.id }
  end
end
