module API

class Work

  attr_accessor :id
  attr_accessor :author_email
  attr_accessor :author_display_name
  attr_accessor :identifier
  attr_accessor :title
  attr_accessor :create_date
  attr_accessor :modified_date
  attr_accessor :status

  def initialize( generic_work )
    @id = generic_work.id
    @author_email = generic_work.author_email
    @author_display_name = 'bla bla bla'
    @identifier = generic_work.identifier
    @title = generic_work.title.join(' ')

    tokens = generic_work.date_created.split( '/' )
    @create_date = DateTime.new( tokens[0].to_i, tokens[1].to_i, tokens[2].to_i ).strftime( "%B %d, %Y" )
    @modified_date = generic_work.date_modified.strftime( "%B %d, %Y" ) if generic_work.date_modified.present?

    if generic_work.is_draft?

      if generic_work.date_modified.present?
         @status = 'in-progress'
      else
        @status = 'pending'
      end
    else
       @status = 'submitted'
    end

  end

end

end
