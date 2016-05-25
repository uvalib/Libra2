class CustomGenericWorkPresenter < Sufia::WorkShowPresenter

  # add our custom fields to the presenter
  delegate :author_email,
           :author_first_name,
           :author_last_name,
           :author_institution,
           :sponsoring_agency,
           :notes,
           :department,
           :degree,
     to: :solr_document

end