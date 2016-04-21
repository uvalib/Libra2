# Generated via
#  `rails generate curation_concerns:work GenericWork`
module CurationConcerns
  class GenericWorkForm < Sufia::Forms::WorkForm
    self.model_class = ::GenericWork
    include HydraEditor::Form::Permissions

    delegate :department,        to: :model
    delegate :degree,            to: :model
    delegate :notes,             to: :model
    delegate :sponsoring_agency, to: :model
    delegate :license,           to: :model

    # additional terms we want on the form
    self.terms += [
#        :title,
#                  :creator,
#                  :contributor,
#                  :description,
#                  :subject,
#                  :language,
#                  :publisher,
#                  :date_created,
#                  :identifier,
#                  :related_url,
        :department,
        :degree,
        :notes,
        :sponsoring_agency,
#                  :rights,
        :license
    ]

    self.terms -= [
        :based_near,
        :tag
    ]

    # override from the base class to remove tag from the list of primary fields
    def primary_terms
      [:title, :creator, :rights]
    end

    # which fields are required...
    def required?(term)
      #puts "=====> required? #{term}"
      return true if [:title, :creator, :contributor, :description, :publisher, :rights, :identifier, :department, :degree, :license].include? term
      false
    end

    # which fields are readonly...
    def readonly?(term)
      #puts "=====> readonly? #{term}"
      return true if [:date_created, :identifier, :publisher, :department, :degree].include? term
      false
    end

  end
end

