# frozen_string_literal: true
class SolrDocument 

  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds CurationConcerns behaviors to the SolrDocument.
  include CurationConcerns::SolrDocumentBehavior
  # Adds Sufia behaviors to the SolrDocument.
  include Sufia::SolrDocumentBehavior

  # self.unique_key = 'id'
  
  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension( Blacklight::Document::Email )
  
  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension( Blacklight::Document::Sms )

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Blacklight::Document::DublinCore)    


  # Do content negotiation for AF models. 

  use_extension( Hydra::ContentNegotiation )

  #
  # Libra2 specific extensions here
  #

  def work_type
    self[Solrizer.solr_name('work_type')]
  end

  def draft
    self[Solrizer.solr_name('draft')]
  end

  def author_institution
    self[Solrizer.solr_name('author_institution')]
  end

  def department
    self[Solrizer.solr_name('department')]
  end

  def degree
    self[Solrizer.solr_name('degree')]
  end

  def notes
    self[Solrizer.solr_name('notes')]
  end

  def license
    self[Solrizer.solr_name('license')]
  end

  def sponsoring_agency
    self[Solrizer.solr_name('sponsoring_agency')]
  end

  def admin_notes
    self[Solrizer.solr_name('admin_notes')]
  end

  def is_thesis?
    return false if work_type.nil?
    return work_type[ 0 ] == GenericWork::WORK_TYPE_THESIS
  end

  def is_draft?
    return false if draft.nil?
    return draft[ 0 ] == 'true'
  end

  def is_mine?( me )
    return false if depositor.nil?
    return depositor == me
  end

  def self.custom_fields()
    return [
        { name: 'department', label: 'Department' },
        { name: 'degree', label: 'Degree' },
        { name: 'notes', label: 'Notes' },
        { name: 'sponsoring_agency', label: 'Sponsoring Agency' }
    ]
  end

  def self.initialize_pre(config)
    fields = self.custom_fields()
    fields.each { |field_def|
      config.add_facet_field Solrizer.solr_name(field_def[:name], :facetable), label: field_def[:label], limit: 5
      config.add_index_field Solrizer.solr_name(field_def[:name], :stored_searchable), label: field_def[:label], itemprop: field_def[:name]
      config.add_show_field Solrizer.solr_name(field_def[:name], :stored_searchable), label: field_def[:label]
    }
  end

  def self.initialize_post(config)
    fields = self.custom_fields()
    fields.each { |field_def|
      config.add_search_field(field_def[:name]) do |field|
        field.solr_parameters = {
            :"spellcheck.dictionary" => field_def[:name]
        }
        solr_name = Solrizer.solr_name(field_def[:name], :stored_searchable)
        field.solr_local_parameters = {
            qf: solr_name,
            pf: solr_name
        }
      end
    }
  end

end
