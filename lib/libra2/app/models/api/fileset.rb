require_dependency 'concerns/libra2/solr_extract'

module API

class Fileset

  include Libra2::SolrExtract

  attr_accessor :id
  attr_accessor :source_name
  attr_accessor :file_name
  attr_accessor :file_size
  attr_accessor :file_url
  attr_accessor :thumb_url

  def initialize
    @id = ''
    @source_name = ''
    @file_name = ''
    @file_size = 0
    @file_url = ''
    @thumb_url = ''
  end

  def from_solr( solr, base_url )

    #puts "==> SOLR #{solr.inspect}"
    @id = solr['id'] unless solr['id'].blank?
    @source_name = solr_extract_first( solr, 'label' )
    @file_name = solr_extract_first( solr, 'title' )
    @file_size = solr_extract_only( solr, 'file_size', 'file_size_is' )
    # handle case where attribute was not found
    @file_size = 0 if @file_size == ''
    @file_size = get_file_size if @file_size == 0

    @file_url, @thumb_url = content_urls( base_url, @id )

    return self
  end

  private

  def content_urls( base, id )
    return "#{download_url( base, id )}/content", "#{download_url( base, id )}/thumbnail"
  end

  def download_url( base, id )
     return "#{base}/downloads/#{id}"
  end

  def get_file_size
    filename = File.join( CurationConcerns.config.working_path, dirname_from_id( @id ), @source_name )
    begin
       st = File.stat( filename )
       return st.size
    rescue Exception => e
      # do nothing
    end
    return 0
  end

  def dirname_from_id( id )
    return '' if id.blank?
    return '' if id.size < 8
    return "#{id[0]}#{id[1]}/#{id[2]}#{id[3]}/#{id[4]}#{id[5]}/#{id[6]}#{id[7]}"
  end

end

end
