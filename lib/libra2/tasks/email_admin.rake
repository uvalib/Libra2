#
# Some helper tasks to manage email submission
#

# pull in the helpers
require_dependency 'libra2/tasks/task_helpers'
include TaskHelpers

namespace :libra2 do

  namespace :email do

  desc "Resend the 'you can submit optional thesis' email; must provide the computing id"
  task send_can_submit_optional: :environment do |t, args|

    computing_id = ARGV[ 1 ]
    if computing_id.nil?
      puts "ERROR: no computing id specified, aborting"
      next
    end

    task computing_id.to_sym do ; end

    user = TaskHelpers.user_info_by_cid( computing_id )
    if user.nil?
      puts "ERROR: user #{computing_id} does not exist, aborting"
      next
    end

    ThesisMailers.optional_thesis_can_be_submitted( user.email, user.display_name ).deliver_later

    puts "Email sent to #{user.email} successfully"

  end

  desc "Resend the 'you can submit sis thesis' email; must provide the computing id"
  task send_can_submit_sis: :environment do |t, args|

    computing_id = ARGV[ 1 ]
    if computing_id.nil?
      puts "ERROR: no computing id specified, aborting"
      next
    end

    task computing_id.to_sym do ; end

    user = TaskHelpers.user_info_by_cid( computing_id )
    if user.nil?
      puts "ERROR: user #{computing_id} does not exist, aborting"
      next
    end

    ThesisMailers.sis_thesis_can_be_submitted( user.email, user.display_name ).deliver_later

    puts "Email sent to #{user.email} successfully"

  end

  desc "Resend the 'thank you for submitting' email to the author; must provide the work id"
  task send_did_submit_author: :environment do |t, args|

    work_id = ARGV[ 1 ]
    if work_id.nil?
      puts "ERROR: no work id specified, aborting"
      next
    end

    task work_id.to_sym do ; end

    work = TaskHelpers.get_work_by_id( work_id )
    if work.nil?
      puts "ERROR: work #{work_id} does not exist, aborting"
      next
    end

    ThesisMailers.thesis_submitted_author( work, "#{work.author_first_name} #{work.author_last_name}" ).deliver_later

    puts "Email sent to #{work.creator} successfully"

  end

  desc "Resend the 'your student submitted' email to the registrar; must provide the work id"
  task send_did_submit_registrar: :environment do |t, args|

    work_id = ARGV[ 1 ]
    if work_id.nil?
      puts "ERROR: no work id specified, aborting"
      next
    end

    task work_id.to_sym do ; end

    work = TaskHelpers.get_work_by_id( work_id )
    if work.nil?
      puts "ERROR: work #{work_id} does not exist, aborting"
      next
    end

    if work.registrar_computing_id.nil?
      puts "ERROR: work does not contain a registrar, aborting"
      next
    end

    registrar = TaskHelpers.user_info_by_cid( work.registrar_computing_id )
    if registrar.nil?
      puts "ERROR: registrar #{work.registrar_computing_id} does not exist, aborting"
      next
    end

    ThesisMailers.thesis_submitted_registrar( work, "#{work.author_first_name} #{work.author_last_name}", registrar.display_name, registrar.email ).deliver_later

    puts "Email sent to #{registrar.email} successfully"

  end

  end   # namespace email

end   # namespace libra2

#
# end of file
#
