module Libra2::SolrExtract

  extend ActiveSupport::Concern

  def solr_extract_only( rec, field, mapping = nil )
    fn = solr_field_name( field, mapping )
    return rec[fn] if rec[fn]
    return ''
  end

  def solr_extract_first( rec, field, mapping = nil )
    fn = solr_field_name( field, mapping )
    return rec[fn][0] if rec[fn]
    return ''
  end

  def solr_extract_all( rec, field, mapping = nil )
    fn = solr_field_name( field, mapping )
    return rec[fn] if rec[fn]
    return []
  end

  def solr_field_name( field, mapping )
    return mapping.nil? ? Solrizer.solr_name( field ) : mapping
  end

end