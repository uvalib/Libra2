require_dependency 'libra2/lib/serviceclient/entity_id_client'
require_dependency 'libra2/lib/serviceclient/deposit_auth_client'

module ServiceHelper

  # update the DOI service metadata
  def update_doi_metadata( work )

    return if work.nil?

    # if we have no DOI, do nothing...
    return if work.identifier.nil? || work.identifier.empty?

    status = ServiceClient::EntityIdClient.instance.metadatasync( work )
    if ServiceClient::EntityIdClient.instance.ok?( status ) == false
      # TODO-DPG handle error
    end
  end

  # update any foreign system that the student has submitted
  def update_submitted_state( work )

    return if work.nil?

    # do nothing for non-SIS work
    return if work.is_sis_thesis? == false

    status = ServiceClient::DepositAuthClient.instance.request_fulfilled( work )
    if ServiceClient::DepositAuthClient.instance.ok?( status ) == false
      # TODO-DPG handle error
    end

  end

end
