# Generated via
#  `rails generate curation_concerns:work Thesis`

class CurationConcerns::ThesesController < ApplicationController
  include CurationConcerns::CurationConcernController
  set_curation_concern_type Thesis
end
