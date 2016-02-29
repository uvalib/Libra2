# Generated via
#  `rails generate curation_concerns:work GenericWork`

require "create_identifier_behavior"

class CurationConcerns::GenericWorksController < ApplicationController
  include CurationConcerns::CurationConcernController
  # Adds Sufia behaviors to the controller.
  include Sufia::WorksControllerBehavior

  # Adds identifier behavior to the controller.
  include Libra2::CreateIdentifierBehavior
end
