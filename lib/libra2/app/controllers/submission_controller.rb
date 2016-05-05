require_dependency 'libra2/lib/helpers/etd_helper'
class SubmissionController < ApplicationController
	include AuthenticationHelper
	before_action :authenticate_user!, except: [ 'development_login']
	layout "public"

	def preview
		@id = params[:id]
		@work = GenericWork.where({ id: @id })
		if @work.length > 0
			@work = @work[0]
		end
	end

	def public_view
		@id = params[:id]
		@work = GenericWork.where({ id: @id })
		if @work.length > 0
			@work = @work[0]
		end
	end

	def submit
		id = params[:id]
		work = GenericWork.where({ id: id })
		if work.length > 0
			work = work[0]
		end
		advisee = Helpers::EtdHelper::lookup_user( work.creator.split("@")[0] )
		adviser = Helpers::EtdHelper::lookup_user( work.creator.split("@")[0] ) # TODO-PER: This should be the advisor's id instead.
		ThesisMailers.thesis_submitted_adviser(work, advisee.display_name, adviser.display_name).deliver_later
		ThesisMailers.thesis_submitted_author(work, advisee.display_name, adviser.display_name).deliver_later
		redirect_to "/public_view/#{id}", :flash => { :notice => "Thank you for submitting your thesis. You have finished this requirement for graduation." }
	end
end
