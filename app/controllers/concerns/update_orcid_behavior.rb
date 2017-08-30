require_dependency 'libra2/lib/serviceclient/orcid_access_client'

module UpdateOrcidBehavior

    extend ActiveSupport::Concern

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
        update_orcid_service( User.cid_from_email( current_user.email ), current_user.orcid.gsub( 'http://orcid.org/', '' ) )
      end
    end

    #
    # Remove the ORCID from the service for the current user
    #
    def remove_orcid
      update_orcid_service( User.cid_from_email( current_user.email ), '' )
    end

    #
    # update the ORCID service with the fact that we have a CID/ORCID association
    #
    def update_orcid_service( cid, orcid )
      return if cid.blank?

      # do we have an orcid to update
      if orcid.blank? == false
         puts "==> setting #{cid} ORCID to: #{orcid}"
         status = ServiceClient::OrcidAccessClient.instance.set_by_cid( cid, orcid )
      else
        puts "==> clearing #{cid} ORCID"
        status = ServiceClient::OrcidAccessClient.instance.del_by_cid( cid )
      end

      if ServiceClient::OrcidAccessClient.instance.ok?( status ) == false
        puts "ERROR: ORCID service returns #{status}"
      end
    end
end
