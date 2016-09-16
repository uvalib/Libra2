module API

class WorkSearch

  attr_accessor :author_email
  attr_accessor :create_date
  attr_accessor :depositor_email
  attr_accessor :modified_date
  attr_accessor :status

  def initialize

    @author_email = ''
    @create_date = ''
    @depositor_email = ''
    @modified_date = ''
    @status = ''

    # the set of fields specified during construction
    @field_set = []
  end

  def from_json( json )

    @author_email = set_field( :author_email, json, '' )
    @create_date = set_field( :create_date, json, '' )
    @depositor_email = set_field( :depositor_email, json, '' )
    @modified_date = set_field( :modified_date, json, '' )
    @status = set_field( :status, json, '' )

    return self
  end

  def valid_for_search?

    # is this suitable for search?
    return true if field_set?( :author_email ) && @author_email.blank? == false
    return true if field_set?( :create_date ) && valid_search_date?( @create_date )
    return true if field_set?( :depositor_email ) && @depositor_email.blank? == false
    return true if field_set?( :modified_date ) && valid_search_date?( @modified_date )
    return true if field_set?( :status ) && ['pending','submitted'].include?( @status )
    return false
  end

  # was this field specifically set during construction
  def field_set?( field )
    return @field_set.include?( field )
  end

  def make_solr_date_search( date )
     dates = date.split( ':' )
     if dates.size == 2
        date_start = '*'
        date_start = "#{dates[0]}T00:00:00Z" if convert_date( dates[ 0 ] ) != nil
        date_end = '*'
        date_end = "#{dates[1]}T23:59:59Z" if convert_date( dates[ 1 ] ) != nil
        return "[#{date_start} TO #{date_end}]"
     end
     return "[#{date}T00:00:00Z TO #{date}T23:59:59Z]"
  end

  private

  def valid_search_date?( date )
    dates = date.split( ':' )
    if dates.size == 2
      return false if convert_date( dates[ 0 ] ) == nil && wildcard( dates[ 0 ] ) == false
      return false if convert_date( dates[ 1 ] ) == nil && wildcard( dates[ 1 ] ) == false
      return true
    end

    return convert_date( date ) != nil
  end

  def convert_date( date )
    begin
      return DateTime.strptime( date, '%Y-%m-%d' )
    rescue => e
      return nil
    end
  end

  def set_field( field, json, default )
    if json.key?( field )
      #puts "==> #{field} was set"
      @field_set << field unless @field_set.include?( field )
      return json[field]
    end
    return default
  end

  def wildcard( d )
    return d == '*'
  end
end

end
