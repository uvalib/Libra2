module Libra
  module ThesisBehavior
    extend ActiveSupport::Concern
    include Sufia::Works::Trophies
    include Sufia::Works::Metadata
    include Sufia::Works::Querying
    include Sufia::WithEvents
    include Sufia::BelongsToUploadSets
    include Libra::Theses::Metadata
  end
end

