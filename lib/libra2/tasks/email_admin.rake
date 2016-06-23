#
# Some helper tasks to manage email submission
#

require_dependency 'libra2/lib/serviceclient/deposit_auth_client'

namespace :libra2 do

  namespace :email do

  desc "Resend the 'you can submit' email; must provide the computing id"
  task send_can_submit: :environment do |t, args|

    computing_id = ARGV[ 1 ]
    if computing_id.nil?
      puts "ERROR: no computing id specified, aborting"
      next
    end

    task computing_id.to_sym do ; end

    user = Helpers::EtdHelper::lookup_user( computing_id )
    if user.nil?
      puts "ERROR: user #{computing_id} does not exist, aborting"
      next
    end

    ThesisMailers.thesis_can_be_submitted( user.email, user.display_name ).deliver_now

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

    work = nil
    begin
      work = GenericWork.find( work_id )
    rescue => e
    end

    if work.nil?
      puts "ERROR: work #{work_id} does not exist, aborting"
      next
    end

    ThesisMailers.thesis_submitted_author( work, "#{work.author_first_name} #{work.author_last_name}" ).deliver_now

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

    work = nil
    begin
      work = GenericWork.find( work_id )
    rescue => e
    end

    if work.nil?
      puts "ERROR: work #{work_id} does not exist, aborting"
      next
    end

    if work.registrar_computing_id.nil?
      puts "ERROR: work does not contain a registrar, aborting"
      next
    end

    registrar = Helpers::EtdHelper::lookup_user( work.registrar_computing_id )
    if registrar.nil?
      puts "ERROR: registrar #{work.registrar_computing_id} does not exist, aborting"
      next
    end

    ThesisMailers.thesis_submitted_registrar( work, "#{work.author_first_name} #{work.author_last_name}", registrar.display_name, registrar.email ).deliver_now

    puts "Email sent to #{registrar.email} successfully"

  end

  end   # namespace email

end   # namespace libra2

#
# end of file
#
