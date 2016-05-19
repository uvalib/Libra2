class CustomGenericWorkPresenter < Sufia::WorkShowPresenter

  # add our custom fields to the presenter
  delegate :sponsoring_agency, :notes, :department,:degree, to: :solr_document

end