class WorkAudit < ActiveRecord::Base

  def self.audit( work_id, user_id, what )
    audit = WorkAudit.new
    audit.work_id = work_id
    audit.user_id = user_id
    audit.what = what
    audit.save!
  end

  # ignore the @field_set when creating JSON
  def as_json(options={})
    options[:except] ||= ['id', 'updated_at']
    super( options )
  end

  def to_s
    return "#{WorkAudit.localtime( created_at )}: #{user_id} updated #{work_id} #{what.squish}"
  end

  def to_tsv
    return "#{WorkAudit.localtime( created_at )}\t#{user_id}\t#{work_id}\t#{what.squish}"
  end

  def self.localtime( datetime )
    return 'unknown' if datetime.blank?
    begin
      return datetime.localtime.strftime( '%Y-%m-%d %H:%M:%S %Z' )
    rescue => ex
      # do nothing
    end
    return datetime
  end

end