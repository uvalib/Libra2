require_dependency 'libra2/lib/serviceclient/orcid_access_client'

module UpdateOrcidBehavior

    extend ActiveSupport::Concern

    included do
      before_action :save_orcid_if_provided, only: [ :update ]
    end

    private

    #
    # save an updated value if appropriate and remove it as it is a special/fake field
    #
    def save_orcid_if_provided
      if params[:generic_work][:my_orcid].blank? == false
        if current_user.orcid != "http://orcid.org/#{params[:generic_work][:my_orcid]}"
          current_user.orcid = params[:generic_work][:my_orcid]
          current_user.save!

          update_orcid_service( User.cid_from_email( current_user.email ), params[:generic_work][:my_orcid] )
        end
        params[:generic_work].delete( :my_orcid )
      end
    end

    #
    # update the ORCID service with the fact that we have a CID/ORCID association
    #
    def update_orcid_service( cid, orcid )
      puts "==> setting #{cid} ORCID to: #{orcid}"
      status = ServiceClient::OrcidAccessClient.instance.set_by_cid( cid, orcid )
      if ServiceClient::OrcidAccessClient.instance.ok?( status ) == false
        puts "ERROR: ORCID service returns #{status}"
      end
    end
end
