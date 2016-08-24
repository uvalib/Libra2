module API

class Work

  attr_accessor :id
  attr_accessor :author_email
  attr_accessor :author_first_name
  attr_accessor :author_last_name

  attr_accessor :identifier
  attr_accessor :title
  attr_accessor :abstract
  attr_accessor :create_date
  attr_accessor :modified_date

  attr_accessor :creator_email
  attr_accessor :embargo_state
  attr_accessor :embargo_period
  attr_accessor :embargo_end_date
  attr_accessor :notes
  attr_accessor :admin_notes

  attr_accessor :status
  attr_accessor :filesets

  def initialize
    @id = ''
    @author_email = ''
    @author_first_name =  ''
    @author_last_name = ''

    @identifier = ''
    @title = ''
    @abstract = ''
    @create_date = ''
    @modified_date = ''

    @creator_email = ''
    @embargo_state = ''
    @embargo_period = ''
    @embargo_end_date = ''
    @notes = ''
    @admin_notes = ''

    @status = ''
    @filesets = []
  end

  def from_json( json )

    @author_email = json[:author_email] unless json[:author_email].blank?
    @author_first_name = json[:author_first_name] unless json[:author_first_name].blank?
    @author_last_name = json[:author_last_name] unless json[:author_last_name].blank?

    @title = json[:title] unless json[:title].blank?
    @abstract = json[:abstract] unless json[:abstract].blank?

    @embargo_state = json[:embargo_state] unless json[:embargo_state].blank?
    @embargo_period = json[:embargo_period] unless json[:embargo_period].blank?
    @embargo_end_date = json[:embargo_end_date] unless json[:embargo_end_date].blank?

    @admin_notes = json[:admin_notes] unless json[:admin_notes].blank?

    return self
  end

  def from_generic_work( generic_work, base_url )

    @id = generic_work.id
    @author_email = generic_work.author_email
    @author_first_name = generic_work.author_first_name
    @author_last_name = generic_work.author_last_name

    @identifier = generic_work.identifier
    @title = generic_work.title.join(' ')
    @abstract = generic_work.description

    @create_date = generic_work.date_created.gsub( '/', '-' )
    @modified_date = generic_work.date_modified

    @creator_email = generic_work.creator
    @embargo_state = generic_work.embargo_state
    @embargo_period = generic_work.embargo_period
    @notes = generic_work.notes

    @admin_notes = generic_work.admin_notes

    if generic_work.is_draft?
      if generic_work.date_modified.present?
         @status = 'in-progress'
      else
        @status = 'pending'
      end
    else
      @status = 'submitted'
      @embargo_end_date = generic_work.embargo_end_date
    end

    if generic_work.file_sets
      generic_work.file_sets.each do |file_set|
        @filesets << API::Fileset.new.from_fileset( file_set, base_url )
      end
    end

    return self
  end

end

end
