module API

class Fileset

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

  def from_fileset( file_set, base_url )

    @id = file_set.id
    @source_name = file_set.label
    @file_name = file_set.title[0]
    @file_url = "#{base_url}/downloads/#{file_set.id}/content"
    @thumb_url = "#{base_url}/downloads/#{file_set.id}/thumbnail"

    return self
  end

end

end
