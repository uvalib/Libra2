
module CurationConcerns
  class GenericWorkForm < Sufia::Forms::WorkForm

    self.model_class = ::GenericWork

    include HydraEditor::Form::Permissions

    self.terms = [:title,
                  :creator,
                  :contributor,
                  :description,
                  :subject,
                  :language,
                  :publisher,
                  :date_created,
    #              :tag,
                  :identifier,
    #              :based_near,
                  :related_url,

                  :department,
                  :degree,
                  :notes,
                  :sponsoring_agency,

    #              :representative_id, :thumbnail_id, :files,
    #              :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo,
    #              :visibility_during_lease, :lease_expiration_date, :visibility_after_lease,
    #              :visibility,
    #              :resource_type

                   :rights,
                   :license
                  ]


  end
end

