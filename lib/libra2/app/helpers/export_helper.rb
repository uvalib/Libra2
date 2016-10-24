module ExportHelper

  def extract_date_from_timestamp_string( ts )
    return '' if ts.blank?
    dates = ts.match( /^(\d{4}-\d{2}-\d{2})/ )
    return dates[ 0 ] if dates
    return ts
  end

end
