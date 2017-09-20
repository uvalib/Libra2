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
                          'registrar_computing_id',
                          object.registrar_computing_id,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'sis_id',
                          object.registrar_computing_id,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'sis_entry',
                          object.sis_entry,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'date_published',
                          object.date_published,
                          :searchable )

      Solrizer.set_field( solr_doc,
                          'thumbnail_url_display',
                          object.thumbnail_url,
                          :displayable )

      Solrizer.set_field( solr_doc,
                          'rights_display',
                          rights_labels(object),
                          :displayable )

      Solrizer.set_field( solr_doc,
                          'rights_url',
                          rights_urls(object),
                          :displayable )

    end
  end

  private
  def rights_labels doc
    doc.rights.map do |r|
      rights(r, 'term')
    end if doc.rights.present?
  end

  def rights_urls doc
    doc.rights.map do |r|
      rights(r, 'url')
    end if doc.rights.present?
  end

  def rights id, term
    CurationConcerns::QaSelectService.new('rights').authority.find(id).fetch(term)
  end

end

#
# end of file
#
