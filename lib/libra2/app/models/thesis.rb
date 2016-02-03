# Generated via
#  `rails generate curation_concerns:work Thesis`

class Thesis < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include Libra::ThesisBehavior
  validates :title, presence: { message: 'Your thesis must have a title.' }

end
