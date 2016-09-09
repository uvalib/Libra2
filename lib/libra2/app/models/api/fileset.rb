require_dependency 'concerns/libra2/solr_extract'

module API

class Fileset

  include Libra2::SolrExtract

  attr_accessor :id
  attr_accessor :source_name
  attr_accessor :file_name
  attr_accessor :file_url
  attr_accessor :thumb_url

  def initialize
    @id = ''
    @source_name = ''
    @file_name = ''
    @file_url = ''
    @thumb_url = ''
  end

  def from_json( json )

    @id = json[:id] unless json[:id].blank?
    @source_name = json[:source_name] unless json[:source_name].blank?
    @file_name = json[:file_name] unless json[:file_name].blank?
    @file_url = json[:file_url] unless json[:file_url].blank?
    @thumb_url = json[:thumb_url] unless json[:thumb_url].blank?

    return self
  end

  def from_solr( solr, base_url )

    @id = solr['id'] unless solr['id'].blank?
    @source_name = solr_extract_first( solr, 'label' )
    @file_name = solr_extract_first( solr, 'title' )
    @file_url, @thumb_url = content_urls( base_url, @id )

    return self
  end

  def from_fileset( file_set, base_url )

    @id = file_set.id
    @source_name = file_set.label
    @file_name = file_set.title[0]
    @file_url, @thumb_url = content_urls( base_url, file_set.id )

    return self
  end

  private

  def content_urls( base, id )
    return "#{download_url( base, id )}/content", "#{download_url( base, id )}/thumbnail"
  end

  def download_url( base, id )
     return "#{base}/downloads/#{id}"
  end
end

end
