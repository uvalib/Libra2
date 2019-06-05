require_dependency 'libraetd/lib/serviceclient/orcid_access_client'
#require_dependency 'libraetd/app/helpers/orcid_helper'

module UpdateOrcidBehavior

  extend ActiveSupport::Concern

  include OrcidHelper

  included do
    after_action :update_orcid, only: [ :landing ]
    after_action :remove_orcid, only: [ :destroy ]
  end

  private

  #
  # Update the ORCID service with the just associated ORCID
  #
  def update_orcid
    if current_user.orcid.present?
      update_orcid_attributes(User.cid_from_email(current_user.email ), current_user )
      OrcidSyncAllJob.perform_later(current_user.id)
    end
  end

  #
  # Remove the ORCID from the service for the current user
  #
  def remove_orcid
    remove_orcid_attributes( User.cid_from_email( current_user.email ) )
    # remove pending statuses
    GenericWork.where(
      orcid_status: GenericWork.pending_orcid_status,
      depositor: current_user.email
    ).each do |work|
      work.update(orcid_status: nil)
    end

  end

  #
  # update the ORCID service with the fact that we have a CID/ORCID association
  #
  def update_orcid_attributes(cid, user )
    return if cid.blank?

    orcid = orcid_from_orcid_url( user.orcid )

    puts "==> updating ORCID attributes for #{cid} (#{orcid})"
    status = ServiceClient::OrcidAccessClient.instance.set_attribs_by_cid(
      cid,
      orcid,
      user.orcid_access_token,
      user.orcid_refresh_token,
      user.orcid_scope )

    if ServiceClient::OrcidAccessClient.instance.ok?( status ) == false
      puts "ERROR: ORCID service returns #{status}"
    end
  end

  #
  # remove ORCID attributes from the service
  #
  def remove_orcid_attributes(cid )
    return if cid.blank?

    puts "==> clearing ORCID attributes for #{cid}"
    status = ServiceClient::OrcidAccessClient.instance.del_attribs_by_cid( cid )

    if ServiceClient::OrcidAccessClient.instance.ok?( status ) == false
      puts "ERROR: ORCID service returns #{status}"
    end
  end

end
