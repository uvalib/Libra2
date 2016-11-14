require_dependency 'libra2/lib/serviceclient/entity_id_client'
require_dependency 'libra2/lib/serviceclient/deposit_auth_client'

module ServiceHelper

  # update the DOI service metadata
  def update_doi_metadata( work )

    return false if work.nil?

    # if we have no DOI, do nothing...
    return true if work.identifier.blank?

    #puts "==> Updating DOI"
    status = ServiceClient::EntityIdClient.instance.metadatasync( work )
    if ServiceClient::EntityIdClient.instance.ok?( status ) == false
      # TODO-DPG handle error
      puts "ERROR: DOI metadata update returns #{status} (#{work.identifier})"
      return false
    end
    return true
  end

  # remove the DOI
  def remove_doi( work )

    return false if work.nil?

    # if we have no DOI, do nothing...
    return true if work.identifier.blank?

    #puts "==> Removing DOI"
    status = ServiceClient::EntityIdClient.instance.remove( work.identifier )
    if ServiceClient::EntityIdClient.instance.ok?( status ) == false
      # TODO-DPG handle error
      puts "ERROR: DOI remove returns #{status} (#{work.identifier})"
      return false
    end
    return true
  end

  # revoke the DOI
  def revoke_doi( work )

    return false if work.nil?

    # if we have no DOI, do nothing...
    return true if work.identifier.blank?

    #puts "==> Revoking DOI"
    status = ServiceClient::EntityIdClient.instance.revoke( work.identifier )
    if ServiceClient::EntityIdClient.instance.ok?( status ) == false
      # TODO-DPG handle error
      puts "ERROR: DOI revoke returns #{status} (#{work.identifier})"
      return false
    end
    return true
  end

  # update any foreign system that the student has submitted
  def update_submitted_state( work )

    return false if work.nil?

    # do nothing for non-SIS work
    return true if work.is_sis_thesis? == false

    status = ServiceClient::DepositAuthClient.instance.request_fulfilled( work )
    if ServiceClient::DepositAuthClient.instance.ok?( status ) == false
      # TODO-DPG handle error
      puts "ERROR: Update submit state returns #{status}"
      return false
    end
    return true
  end

end
