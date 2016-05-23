module CurationConcerns

  class GenericWorksController < ApplicationController

    include CurationConcerns::CurationConcernController

    # Adds Sufia behaviors to the controller.
    include Sufia::WorksControllerBehavior

    # Adds identifier behavior to the controller.
    include Libra2::CreateIdentifierBehavior

    # Adds license application behavior to the controller.
    include Libra2::ApplyLicenseBehavior

    self.curation_concern_type = GenericWork

    # use our custom presenter
    self.show_presenter = CustomGenericWorkPresenter
  end
end
