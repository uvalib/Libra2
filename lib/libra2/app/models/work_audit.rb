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

end