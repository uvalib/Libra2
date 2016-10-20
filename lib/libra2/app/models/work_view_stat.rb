require_dependency 'libra2/statistic'

class WorkViewStat < Libra2::Statistic
  self.cache_column = :work_views
  self.event_type = :pageviews

  def self.filter(work)
    { work_id: work.id }
  end
end
