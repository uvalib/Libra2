class OrcidSyncJob < BaseOrcidJob

  include ::WorkHelper
  include ::OrcidHelper

  queue_as :orcid

  #
  # Creates or updates a LibraWork in the OrcidService
  #
  def perform work_id, user_id

    work = get_generic_work(work_id)
    return if work.nil?

    user = nil
    begin
       user = User.find(user_id)
    rescue ActiveRecord::RecordNotFound => ex
       puts "==> ERROR: cannot find user #{user_id} (#{ex})"
       return
    end

    computing_id = user.computing_id

    suitable, why = work_suitable_for_orcid_activity( computing_id, work )

    if user.orcid.blank?
      suitable, why = false, 'ORCID not linked for user'
    end

    if suitable == false
      puts "INFO: work #{work.id} is unsuitable to report as activity for #{computing_id} (#{why})"
      return
    end
    work.update orcid_status: GenericWork.pending_orcid_status

    status, update_code = ServiceClient::OrcidAccessClient.instance.
      set_activity_by_cid( computing_id, work )

    if ServiceClient::OrcidAccessClient.instance.ok?( status )
      work.update orcid_put_code: update_code, orcid_status: GenericWork.complete_orcid_status,
                  orcid_author_url: user.orcid
      puts "==> ORCID Upload OK for #{work_id}, update code [#{update_code}]"

    elsif ServiceClient::OrcidAccessClient.instance.retry?( status )
      puts "RETRYING: OrcidSyncJob for #{work_id}"
      retry_job wait: 5.minutes

    else
      # fail on other errors
      puts "ERROR: OrcidSyncJob for #{work_id}"
      work.update orcid_status: GenericWork.error_orcid_status
      return
    end

  end
end
