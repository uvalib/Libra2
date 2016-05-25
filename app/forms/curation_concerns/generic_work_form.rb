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
    delegate :visibility_during_embargo,  to: :model
    delegate :contributor,  to: :model

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
        :subject
    ]

    #NESTED_ASSOCIATIONS = [:contributor].freeze

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

    def initialize_fields
      puts "=====> GenericWorkForm.initialize_fields"
      # we're making a local copy of the attributes that we can modify.
      @attributes = model.attributes
      terms.each { |key| initialize_field(key) }
    end

    def initialize_field(key)
      puts "=====> GenericWorkForm.initialize_field #{key}"
      return super unless [:contributor].include?(key)
      #if key == :contributor
      self[key] = Contributor.new( self.contributor )
      #end
    end

    def self.build_permitted_params
      puts "=====> GenericWorkForm.build_permitted_params"
      permitted = super
      permitted + [:embargo_period, :visibility_during_embargo, :on_behalf_of, :rights, { collection_ids: [] }]
      permitted << { contributors_attributes: permitted_contributors_params }
      permitted
    end

    def self.permitted_contributors_params
      [ :id, :_destroy, :first_name, :last_name ]
    end

    class Contributor

      attr_reader :predicate, :model

      def initialize( model, predicate = nil )
        @model = model
        @predicate = predicate
      end

      def first_name
        @model.first_name
      end

      def last_name
        @model.last_name
      end

      #def node?
      #  @model.respond_to?(:node?) ? @model.node? : false
      #end
    end

  end
end

