class OrcidSyncAllJob < BaseOrcidJob

  queue_as :orcid

  #
  # Syncs all LibraWorks for a newly linked ORCID User
  #
  def perform(user_id)

    user = User.find(user_id)
    if user.orcid.present?
      GenericWork.where(depositor: user.email).each do |work|

        # Sync non-complete Works
        if work.orcid_status != GenericWork.complete_orcid_status
          OrcidSyncJob.perform_later(work.id, user.id)
        end
      end
    end
  end

end
