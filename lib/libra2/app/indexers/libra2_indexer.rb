class Libra2Indexer < CurationConcerns::WorkIndexer

  def generate_solr_document
    super.tap do |solr_doc|
      Solrizer.set_field( solr_doc,
                         'author_institution',
                         object.author_institution,
                         :searchable )

      Solrizer.set_field( solr_doc,
                          'department',
                          object.department,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'degree',
                          object.degree,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'notes',
                          object.notes,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'license',
                          object.license,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'sponsoring_agency',
                          object.sponsoring_agency,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'admin_notes',
                          object.admin_notes,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'embargo_period',
                          object.embargo_period,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'visibility_during_embargo',
                          object.visibility_during_embargo,
                          :searchable )
    end
  end

end

#
# end of file
#