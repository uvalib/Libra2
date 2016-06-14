class Libra2Indexer < CurationConcerns::WorkIndexer

  def generate_solr_document
    super.tap do |solr_doc|

      Solrizer.set_field( solr_doc,
                         'author_email',
                         object.author_email,
                         :searchable )

      Solrizer.set_field( solr_doc,
                          'author_first_name',
                          object.author_first_name,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'author_last_name',
                          object.author_last_name,
                          :searchable )

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
                          'embargo_state',
                          object.embargo_state,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'embargo_end_date',
                          object.embargo_end_date,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'visibility_during_embargo',
                          object.visibility_during_embargo,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'permanent_url',
                          object.permanent_url,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'contributor_computing_id',
                          object.contributor_computing_id,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'contributor_first_name',
                          object.contributor_first_name,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'contributor_last_name',
                          object.contributor_last_name,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'contributor_institution',
                          object.contributor_institution,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'contributor_department',
                          object.contributor_department,
                          :searchable )
    end
  end

end

#
# end of file
#