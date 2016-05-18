require_dependency 'libra2/lib/serviceclient/entity_id_client'
require_dependency 'libra2/lib/helpers/etd_helper'

class SubmissionController < ApplicationController
	include AuthenticationHelper
  include UrlHelper

	before_action :authenticate_user!, except: [ 'development_login']
	layout "public"

	def public_view
		@id = params[:id]
		@work = get_work_item
		if @work.present?
			file_sets = @work.file_sets
			@files = []
			file_sets.each { |file|
				@files.push({
					title: file.title.join(" "),
					location: download_path(file),
					size: file.file_size.join(" "),
					date: file.date_created
				})
			}
			@is_preview = @work.draft == "true"
		else
			redirect_to "/404.html", status: 404
		end
	end

	def submit
		id = params[:id]
    work = get_work_item
		work.draft = false
		work.save!

    author = nil
    adviser = nil
    author = Helpers::EtdHelper::lookup_user( work.creator.split("@")[0] ) unless work.nil?
    # TODO-PER: This should be the advisor's id instead.
    adviser = Helpers::EtdHelper::lookup_user( work.creator.split("@")[0] ) unless work.nil?

    ThesisMailers.thesis_submitted_adviser( work, author.display_name, adviser.display_name ).deliver_later unless author.nil? || adviser.nil?
    ThesisMailers.thesis_submitted_author( work, author.display_name ).deliver_later unless author.nil?

    # TODO-DPG: check status and log, etc
    status = ServiceClient::EntityIdClient.instance.metadatasync( work ) unless work.nil?

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

  def get_work_item
    id = params[:id]
    work = GenericWork.where({ id: id })
    if work.length > 0
      return work[ 0 ]
    end
    return nil
  end

end
