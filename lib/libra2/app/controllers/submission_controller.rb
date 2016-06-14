require_dependency 'libra2/lib/serviceclient/entity_id_client'
require_dependency 'libra2/lib/serviceclient/deposit_auth_client'
require_dependency 'libra2/lib/helpers/etd_helper'

class SubmissionController < ApplicationController
	include AuthenticationHelper
  include UrlHelper

	before_action :authenticate_user!, only: [ 'submit']
	layout "public"

	def public_view
		@id = params[:id]
		@work = get_work_item
		if can_view(@work)
			file_sets = @work.file_sets
			@files = []
			file_sets.each { |file|
				@files.push({
					title: file.title.join(" "),
					location: download_path(file),
					date: file.date_uploaded
				})
			}
			@files = @files.sort { |a,b|
				a[:title].downcase <=> b[:title].downcase
			}
			@is_preview = @work.draft == "true"
		else
			raise CanCan::AccessDenied.new(nil, :show)
		end
	end

	def submit
		id = params[:id]
    work = get_work_item
		work.draft = false
		if work.embargo_state != Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
			work.embargo_date = work.resolve_embargo_date()
		end
		work.save!

		# send the author email that they have successfully completed things
		send_author_email( work )

		# update the DOI service with the completed metadata
		update_metadata( work )

		# update SIS as necessary
		update_submitted_state( work )

		redirect_to locally_hosted_work_url( id ), :flash => { :notice => "Thank you for submitting your thesis. You have finished this requirement for graduation." }
  end

	def unpublish
		if ENV['ALLOW_FAKE_NETBADGE'] == 'true'
			id = params[:id]
			work = get_work_item
			work.draft = "true"
			work.save!
			redirect_to locally_hosted_work_url( id )
		end
	end

  private

	# send the author email that they have successfully completed things
	def send_author_email( work )
		author = nil
		author = Helpers::EtdHelper::lookup_user( work.creator.split("@")[0] ) unless work.nil?
		ThesisMailers.thesis_submitted_author( work, author.display_name ).deliver_later unless author.nil?

	end

	# update the DOI service metadata
	def update_metadata( work )

		# if we have no DOI, do nothing...
		return if work.identifier.empty?

		status = ServiceClient::EntityIdClient.instance.metadatasync( work ) unless work.nil?
		if ServiceClient::EntityIdClient.instance.ok?( status ) == false
			# TODO-DPG handle error
		end
	end

	# update any foreign system that the student has submitted
	def update_submitted_state( work )

		# do nothing for non-SIS work
		return if work.is_sis_thesis? == false

		status = ServiceClient::DepositAuthClient.instance.request_fulfilled( work )
		if ServiceClient::DepositAuthClient.instance.ok?( status ) == false
			# TODO-DPG handle error
		end

	end

  def get_work_item
    id = params[:id]
    work = GenericWork.where({ id: id })
    if work.length > 0
      return work[ 0 ]
    end
    return nil
  end

	def can_view(work)
		# can view if the work exists and is published, or if it is draft and the owner is logged in.
		return false if !work.present? # bad URL passed in: the work doesn't exist.
		return true if current_user.present? && work.author_email == current_user.email # this work is owned by the current user.
		return !work.is_draft? # This work has been published.
	end
end
