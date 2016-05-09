# Generated via
#  `rails generate curation_concerns:work GenericWork`
module CurationConcerns
  class GenericWorkForm < Sufia::Forms::WorkForm
    self.model_class = ::GenericWork
#    include HydraEditor::Form::Permissions

    delegate :department,        to: :model
    delegate :degree,            to: :model
    delegate :notes,             to: :model
    delegate :sponsoring_agency, to: :model
    delegate :license,           to: :model

    # additional terms we want on the form
    self.terms += [
#        :title,
#        :creator,
#        :contributor,
#        :description,
#        :subject,
#        :language,
#        :publisher,
#        :date_created,
#        :identifier,
#        :related_url,
        :department,
        :degree,
        :notes,
        :sponsoring_agency,
#        :rights,
#        :license
    ]

    self.terms -= [
        :identifier,
        :based_near,
        :tag
    ]

    # override from the base class to remove tag from the list of primary fields
    # we also do some logic here to ensure that the deposit agreement must be accepted once
    def primary_terms
      @agreement_accepted = GenericWork.accepted_agreement?( self.license )
      [:title, :creator, :rights]
    end

    # which fields are required...
    def required?(term)
      #puts "=====> GenericWorkForm.required? #{term}"
      GenericWork.required?( term )
    end

    # which fields are readonly...
    def readonly?(term)
      #puts "=====> GenericWorkForm.readonly? #{term}"
      GenericWork.readonly?( term )
    end

    def multiple?(term)
      #puts "=====> GenericWorkForm.multiple? #{term}"
      GenericWork.multiple?( term )
    end

    def self.build_permitted_params
      #puts "=====> GenericWorkForm.build_permitted_params"
      super + [:on_behalf_of, :rights, { collection_ids: [] }]
    end
  end
end

