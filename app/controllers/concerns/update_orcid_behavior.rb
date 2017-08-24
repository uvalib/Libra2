require_dependency 'libraetd/lib/serviceclient/orcid_access_client'

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
        # supplied ORCID is not blank...
        if current_user.orcid != "http://orcid.org/#{params[:generic_work][:my_orcid]}"
          current_user.orcid = params[:generic_work][:my_orcid]
          current_user.save!
          update_orcid_service( User.cid_from_email( current_user.email ), params[:generic_work][:my_orcid] )
        end
      else
        # supplied ORCID is blank...
        if current_user.orcid.blank? == false
          current_user.orcid = ''
          current_user.save!
          update_orcid_service( User.cid_from_email( current_user.email ), '' )
        end
      end
      params[:generic_work].delete( :my_orcid ) if params[:generic_work][:my_orcid]
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
