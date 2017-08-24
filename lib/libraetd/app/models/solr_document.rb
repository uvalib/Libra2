# frozen_string_literal: true
class SolrDocument 

  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds CurationConcerns behaviors to the SolrDocument.
  include CurationConcerns::SolrDocumentBehavior
  # Adds Sufia behaviors to the SolrDocument.
  include Sufia::SolrDocumentBehavior

  # just a way to provide common functionality
  include Libra2::OrcidBehavior

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

  def embargo_end_date
    self[Solrizer.solr_name('embargo_end_date')]
  end

  def embargo_period
    self[Solrizer.solr_name('embargo_period')]
  end

  def embargo_state
    x = self[Solrizer.solr_name('embargo_state')]
    x = x.join("") if x.kind_of?(Array)
      return x
  end

  def work_source
    self[Solrizer.solr_name('work_source')]
  end

  def author_email
    self[Solrizer.solr_name('author_email')]
  end

  def author_first_name
    self[Solrizer.solr_name('author_first_name')]
  end

  def author_last_name
    self[Solrizer.solr_name('author_last_name')]
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

  def permanent_url
    self[Solrizer.solr_name('permanent_url')]
  end

  def registrar_computing_id
    self[Solrizer.solr_name('registrar_computing_id')]
  end

  def sis_id
    self[Solrizer.solr_name('sis_id')]
  end

  def sis_entry
    self[Solrizer.solr_name('sis_entry')]
  end

  def contributor
    contributors = self[Solrizer.solr_name('contributor')]
    return [] if contributors.nil?

    advisors = []

    # advisers are tagged with a numeric index so sorting them ensures they are presented in the correct order
    contributors = contributors.sort

    contributors.each_with_index { |person, index|
      arr = person.split("\n")

      arr.push('') if arr.length == 4 # if the last item is empty, the split command will miss it.
      arr.push('') if arr.length == 5 # if the last item is empty, the split command will miss it.

      if arr.length == 6
        advisors.push("First Name: #{arr[2]}")
        advisors.push("Last Name: #{arr[3]}")
        advisors.push("Department: #{arr[4]}")
        advisors.push("Institution: #{arr[5]}")
      else
        advisors.push(person) # this shouldn't happen, but perhaps it will if old data gets in there.
      end
      advisors.push("---") if index < contributors.length - 1
    }
    return advisors
  end

  def date_published
    self[Solrizer.solr_name('date_published')]
  end

  def is_thesis?
    return false if work_type.nil?
    return work_type[ 0 ] == GenericWork::WORK_TYPE_THESIS
  end

  def is_draft?
    return false if draft.nil?
    return draft[ 0 ] == 'true'
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
