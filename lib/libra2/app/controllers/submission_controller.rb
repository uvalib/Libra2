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
		ThesisMailers.thesis_submitted(work).deliver_now
		redirect_to "/public_view/#{id}", :flash => { :notice => "Thank you for your submission. You have finished this requirement for graduation." }
	end
end
