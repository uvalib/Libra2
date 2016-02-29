require "lib/entityid/entity_id_client"

module Libra2

  module CreateIdentifierBehavior
    extend ActiveSupport::Concern

    included do
      before_action :add_identifier, only: [:new]
    end

    private

    # get a DOI from the service
    def add_identifier
      status, id = Libra2::EntityIdClient.newid( curation_concern )
      curation_concern.identifier << id if Libra2::EntityIdClient.ok?( status )
    end

  end
end
