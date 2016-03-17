require_dependency 'libra2/lib/serviceclient/entity_id_client'

module CreateIdentifierBehavior
    extend ActiveSupport::Concern

    included do
      before_action :add_identifier, only: [:new]
    end

    private

    # get a DOI from the service
    def add_identifier
      status, id = ServiceClient::EntityIdClient.instance.newid( curation_concern )
      curation_concern.identifier = id if ServiceClient::EntityIdClient.instance.ok?( status )
    end

end
