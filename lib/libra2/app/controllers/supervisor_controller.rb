require_dependency 'libra2/tasks/task_helpers'
include TaskHelpers

require_dependency 'libra2/lib/serviceclient/deposit_reg_client'
require_dependency 'libra2/lib/serviceclient/deposit_auth_client'
require_dependency 'libra2/lib/helpers/value_snapshot'
require_dependency 'libra2/lib/helpers/deposit_request'
require_dependency 'libra2/lib/helpers/deposit_authorization'
require_dependency 'libra2/lib/helpers/etd_helper'
require_dependency 'libra2/lib/helpers/timed_token'

class SupervisorController < ApplicationController
	before_action :must_be_supervisor

	def index
		works = GenericWork.all

		@untouched = []
		@in_progress = []
		@submitted = []
		ldap = ServiceClient::UserInfoClient.instance
		works.each do |generic_work|
			work = {id: generic_work.id, email: generic_work.author_email, identifier: generic_work.identifier, title: generic_work.title.join(' ')}
			arr = generic_work.date_created.split("/")
			work[:created] = DateTime.new(arr[0].to_i,arr[1].to_i,arr[2].to_i).strftime("%B %d, %Y")
			work[:modified] = generic_work.date_modified.strftime("%B %d, %Y") if generic_work.date_modified.present?
			computing_id = generic_work.author_email.split("@")[0]
			status, resp = ldap.get_by_id( computing_id )
			if status == 200
				work[:name] = resp['display_name']
			end
			if generic_work.draft == 'true'
				if work[:modified].present?
					@in_progress.push(work)
				else
					@untouched.push(work)
				end
			else
				@submitted.push(work)
			end
			@untouched = @untouched.sort { |a, b|
				a[:email] <=> b[:email]
			}
			@in_progress = @in_progress.sort { |a, b|
				a[:email] <=> b[:email]
			}
			@submitted = @submitted.sort { |a, b|
				a[:email] <=> b[:email]
			}
		end
	end

	def title
		id = params[:identifier]
		title = params[:title]
		work = GenericWork.where(id: id)
		if work.length > 0
			work = work[0]
			work.title = [ title ]
			work.save!
		end
		redirect_to :back
	end

	def sis
		sis_file = "#{Rails.root}/tmp/from_sis/UV_Libra_From_SIS_160721.txt"
		@sis_new = []
		@sis_changed = []
		f = File.open(sis_file, "r")
		f.each_line do |line|
			line = line.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '[BAD CHAR]')
			arr = line.split("|")
			work = GenericWork.where({ sis_id: arr[0] })
			if work.length == 0
				# the work has never been imported before
				@sis_new.push({ sis_id: arr[0], sis_entry: line, computing_id: arr[1], name: "#{arr[2]} #{arr[3]} #{arr[4]}", title: arr[8] })
			elsif work[0].sis_entry == line
				# the work is exactly the same as what was imported before
			else
				# The work was imported, but with a change. Probably the title changed.
				@sis_changed.push({ sis_id: arr[0], sis_entry: line, computing_id: arr[1], name: "#{arr[2]} #{arr[3]} #{arr[4]}", title: arr[8], work: work[0] })
			end
		end

	end

	def sis_import
		line = params[:sis_entry]
		arr = line.split("|")
		entry = {
			'id' => arr[0],
			'computing_id' => arr[1],
			'first_name' => arr[2],
			'last_name' => arr[4],
			'title' => arr[8],
			'department' => arr[7],
			'degree' => arr[10]
		}
		req = Helpers::DepositAuthorization.create( entry )
		if Helpers::EtdHelper::new_etd_from_sis_request( req ) == true
			work = GenericWork.where({ work_source: "#{GenericWork::THESIS_SOURCE_SIS}:#{arr[0]}"})
			work.sis_id = arr[0]
			work.sis_entry = line
			work.save!
			user = Helpers::EtdHelper::lookup_user( req.who )
			ThesisMailers.sis_thesis_can_be_submitted( user.email, user.display_name ).deliver_now
			puts "Created placeholder (SIS) ETD for #{req.who} (request #{req.id})"
		else
			puts "ERROR ingesting sis authorization #{req.id} for #{req.who}; ignoring"
		end
		redirect_to :back
	end

  private
	def must_be_supervisor
		return false if !user_signed_in?
		return true if current_user.email == "per4k@eservices.virginia.edu"
		return true if current_user.email == "dpg3k@virginia.edu"
		return true if current_user.email == "ecr2c@virginia.edu"
		return true if current_user.email == "sah@virginia.edu"
		return false
	end


end
