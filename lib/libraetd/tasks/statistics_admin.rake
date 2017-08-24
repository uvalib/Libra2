#
# Some helper tasks to manage view and download statistics
#

require_dependency 'libraetd/app/helpers/statistics_helper'
include StatisticsHelper

namespace :libraetd do

  namespace :statistics do

  desc "Delete all aggregate user statistics"
  task delete_aggregate: :environment do |t, args|

    count = UserStat.count
    if count != 0
       UserStat.delete_all
       puts "#{count} statistic(s) deleted successfully"
    else
      puts "No aggregate statistics available"
    end

  end

  desc "Create yesterdays aggregate user statistics"
  task create_yesterdays_aggregate: :environment do |t, args|
    aggregate_statistics_for_day( formatted_yyyymmdd( Date.yesterday ) )
  end

  desc "Create all aggregate user statistics"
  task create_all_aggregate: :environment do |t, args|

    date_min, date_max = full_date_range
    if date_min && date_max
       Date.new( date_min.year, date_min.month, date_min.day ).upto(
          Date.new( date_max.year, date_max.month, date_max.day ) ) do |date|
          aggregate_statistics_for_day( formatted_yyyymmdd( date ) )
       end
    end
  end

  desc "Anonymize work view statistics"
  task anonymize_work_views: :environment do |t, args|

     view_events = get_all_identified_view_events
     view_events.each do |event|
        anonymize_work_view_event( event )
     end
     puts "#{view_events.length} view statistic(s) anomymized"
  end

  desc "Anonymize file download statistics"
  task anonymize_file_downloads: :environment do |t, args|

     download_events = get_all_identified_download_events
     download_events.each do |event|
        anonymize_file_download_event( event )
     end
     puts "#{download_events.length} download statistic(s) anomymized"

  end

  private

  def aggregate_statistics_for_day( day )
    work_views, file_downloads = statistics_for_day( day )
    if work_views.empty? == false || file_downloads.empty? == false

      puts "Aggregating #{work_views.count} view statistic(s) from #{day}"
      puts "Aggregating #{file_downloads.count} download statistic(s) from #{day}"

      # delete any existing aggregate statistics
      UserStat.delete_all( [ 'date = ?', day ] )

      user_rollup = {}

      work_views.each { |view|
         stats = { views: 0, downloads: 0 }
         if user_rollup.has_key?( view.user_id )
            stats = user_rollup[ view.user_id ]
         end
         stats[:views] += view.work_views
         user_rollup[ view.user_id ] = stats
      }

      file_downloads.each { |download|
        stats = { views: 0, downloads: 0 }
        if user_rollup.has_key?( download.user_id )
          stats = user_rollup[ download.user_id ]
        end
        stats[:downloads] += download.downloads
        user_rollup[ download.user_id ] = stats
      }

      user_rollup.keys.each { |user|
        stats = user_rollup[user]
        save_rollup( day, user, stats[:views], stats[:downloads] )
      }

      puts "Created #{user_rollup.count} aggregate statistic(s) for #{day}"

    else
      puts "No statistics from #{day} to aggregate"
    end
  end

  def statistics_for_day( day )
    work_views = WorkViewStat.where( 'date = ? AND user_id IS NOT NULL', day )
    file_downloads = FileDownloadStat.where( 'date = ? AND user_id IS NOT NULL', day )
    return work_views, file_downloads
  end

  def formatted_yyyymmdd( date )
     return date.strftime( "%Y-%m-%d 00:00:00" )
  end

  def save_rollup( date, user, views, downloads )
    rollup = UserStat.new
    rollup.user_id = user
    rollup.date = date
    rollup.file_views = 0
    rollup.file_downloads = downloads
    rollup.work_views = views
    rollup.save!
  end

  def full_date_range
    view_min, view_max = min_max_dates( WorkViewStat )
    download_min, download_max = min_max_dates( FileDownloadStat )
    min = view_min < download_min ? view_min : download_min
    max = view_max > download_max ? view_max : download_max
    return min, max
  end

  def min_max_dates( klass )
     minimum = klass.minimum( :date )
     maximum = klass.maximum( :date )
     return minimum, maximum
  end

end   # namespace statistics

end   # namespace libraetd

#
# end of file
#
