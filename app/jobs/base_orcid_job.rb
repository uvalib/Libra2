require_dependency 'libraetd/lib/serviceclient/orcid_access_client'

class BaseOrcidJob < ActiveJob::Base
    include ::OrcidHelper

end
