require_dependency 'libra2/statistic'

class FileViewStat < Libra2::Statistic
  self.cache_column = :views
  self.event_type = :pageviews

  def self.filter(file)
    { file_id: file.id }
  end
end
