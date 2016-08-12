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
  attr_accessor :files

  def initialize( generic_work )

    @id = generic_work.id
    @author_email = generic_work.author_email
    @author_first_name = generic_work.author_first_name
    @author_last_name = generic_work.author_last_name

    @identifier = generic_work.identifier
    @title = generic_work.title.join(' ')
    @abstract = generic_work.description if generic_work.description.present?

    @create_date = generic_work.date_created.gsub( '/', '-' )
    @modified_date = generic_work.date_modified if generic_work.date_modified.present?

    @creator_email = generic_work.creator
    @embargo_state = generic_work.embargo_state
    @embargo_period = generic_work.embargo_period if generic_work.embargo_period.present?
    @notes = generic_work.notes if generic_work.notes.present?

    @admin_notes = generic_work.admin_notes if generic_work.admin_notes.present?

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
      @files = []
      generic_work.file_sets.each do |file_set|
        @files << { "#{file_set.id}" => { "label" => file_set.label, "title" => file_set.title[0] } }
      end
    end
  end

end

end
