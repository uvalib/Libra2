

class APIV1AuditController < APIBaseController

  def search
    start_date = normalize_start_date( params[ :start ] )
    end_date = normalize_end_date( params[ :end ] )

    audits = WorkAudit.where( 'created_at >= ? AND created_at <= ?', start_date, end_date ).order( created_at: :desc )
    render_audit_list_response( :ok, audits )
  end

  def by_work
    audits = WorkAudit.where( 'work_id = ?', params[:id] ).order( created_at: :desc )
    render_audit_list_response( :ok, audits )
  end

  def by_user
    audits = WorkAudit.where( 'user_id = ?', params[:id] ).order( created_at: :desc )
    render_audit_list_response( :ok, audits )
  end

  private

  def normalize_start_date( date )
    return '2000-01-01'
  end

  def normalize_end_date( date )
    return '2999-01-01'
  end

  def render_audit_list_response( status, audits = [], message = nil )
    render json: API::AuditListResponse.new( status, audits, message ), :status => status
  end

end


