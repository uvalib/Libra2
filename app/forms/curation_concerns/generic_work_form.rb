# Generated via
#  `rails generate curation_concerns:work GenericWork`
module CurationConcerns
  class GenericWorkForm < Sufia::Forms::WorkForm
    self.model_class = ::GenericWork

    attr_accessor :file_sets

    delegate :department,                 to: :model
    delegate :degree,                     to: :model
    delegate :notes,                      to: :model
    delegate :sponsoring_agency,          to: :model
    delegate :license,                    to: :model
    delegate :embargo_period,             to: :model
    delegate :embargo_state,             to: :model
    delegate :embargo_end_date,             to: :model
    delegate :visibility_during_embargo,  to: :model

    #delegate :required?,  to: :model
    #delegate :readonly?,  to: :model
    #delegate :multiple?,  to: :model

    self.terms = [
        :title,
        :author_first_name,
        :author_last_name,
        :department,
        :author_institution,

        :contributor,
        :description,
        :rights,
        :keyword,
        :language,

        :related_url,
        :sponsoring_agency,
        :notes,

        :degree,

        :date_created,

        # required by sufia
        :representative_id,
        :thumbnail_id,
        :files,
        :visibility_during_embargo,
        :embargo_release_date,
        :visibility_after_embargo,
        :visibility_during_lease,
        :lease_expiration_date,
        :visibility_after_lease,
        :visibility,
        :ordered_member_ids,
        :collection_ids,
    ]

    def initialize( model, current_ability )
      #puts "=====> GenericWorkForm.initialize"
      super( model, current_ability )
      @agreement_accepted = model.accepted_agreement?
    end

    # override from the base class to remove tag from the list of primary fields
    # we also do some logic here to ensure that the deposit agreement must be accepted once
    def primary_terms
      [ ]
    end

    # which fields are required...
    def required?( term )
      #puts "=====> GenericWorkForm.required? #{term}"
      model.term_required?( term )
    end

    # which fields are readonly...
    def readonly?( term )
      #puts "=====> GenericWorkForm.readonly? #{term}"
      model.term_readonly?( term )
    end

    def multiple?( term )
      #puts "=====> GenericWorkForm.multiple? #{term}"
      model.term_multiple?( term )
    end

    def self.build_permitted_params
      #puts "=====> GenericWorkForm.build_permitted_params"
      super + [
          # { contributor_computing_id: [] },
          # { contributor_first_name: [] },
          # { contributor_department: [] },
          # { contributor_last_name: [] },
          # { contributor_institution: [] },
          :embargo_state, :embargo_end_date, :embargo_period, :visibility_during_embargo, :on_behalf_of, :rights, { collection_ids: [] }]
    end
  end
end

