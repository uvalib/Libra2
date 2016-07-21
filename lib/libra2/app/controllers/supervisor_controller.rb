require_dependency 'libra2/lib/helpers/etd_helper'

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
