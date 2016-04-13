# Generated via
#  `rails generate curation_concerns:work GenericWork`
module CurationConcerns
  class GenericWorkForm < Sufia::Forms::WorkForm
    self.model_class = ::GenericWork
    include HydraEditor::Form::Permissions

    self.terms += [
                  :title,
#                  :creator,
#                  :contributor,
#                  :description,
#                  :subject,
#                  :language,
#                  :publisher,
#                  :date_created,
    #              :tag,
#                  :identifier,
    #              :based_near,
#                  :related_url,

                  :department,
                  :degree,
                  :notes,
                  :sponsoring_agency,

#                  :rights,
                  :license
                  ]

    self.terms -= [ :tag, :based_near ]
  end
end

