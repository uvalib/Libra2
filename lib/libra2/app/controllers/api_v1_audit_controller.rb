

class APIV1AuditController < APIBaseController

  DEFAULT_DATE_FORMAT = '%Y-%m-%d'
  DEFAULT_START_DATE = '2000-01-01'
  DEFAULT_END_DATE = '2999-01-01'

  def search
    start_date = normalize_start_date( params[ :start ] )
    end_date = normalize_end_date( params[ :end ] )

    audits = WorkAudit.where( 'created_at >= ? AND created_at <= ?', start_date, end_date ).order( created_at: :desc )
    render_audit_list_response( audits.empty? ? :not_found : :ok, audits )
  end

  def by_work
    audits = WorkAudit.where( 'work_id = ?', params[:id] ).order( created_at: :desc )
    render_audit_list_response( audits.empty? ? :not_found : :ok, audits )
  end

  def by_user
    audits = WorkAudit.where( 'user_id = ?', params[:id] ).order( created_at: :desc )
    render_audit_list_response( audits.empty? ? :not_found : :ok, audits )
  end

  private

  def normalize_start_date( date )
    return "#{normalize_date( date, DEFAULT_START_DATE )} 00:00:00"
  end

  def normalize_end_date( date )
    return "#{normalize_date( date, DEFAULT_END_DATE )} 23:59:59"
  end

  def normalize_date( date, default_date )
    return default_date if date.nil?
    dt = convert_date( date )
    return default_date if dt.nil?
    return dt.strftime( DEFAULT_DATE_FORMAT )
  end

  def convert_date( date )
    begin
      return DateTime.strptime( date, DEFAULT_DATE_FORMAT )
    rescue => e
      return nil
    end
  end

  def render_audit_list_response( status, audits = [], message = nil )
    render json: API::AuditListResponse.new( status, audits, message ), :status => status
  end

end


