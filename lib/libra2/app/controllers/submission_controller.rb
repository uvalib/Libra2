require_dependency 'libra2/lib/serviceclient/entity_id_client'

class SubmissionController < ApplicationController
	include AuthenticationHelper
  include UrlHelper

	before_action :authenticate_user!, except: [ 'development_login']
	layout "public"

	def preview
		@id = params[:id]
		@work = get_work_item
	end

	def public_view
		@id = params[:id]
    @work = get_work_item
	end

	def submit
		id = params[:id]
    work = get_work_item
		ThesisMailers.thesis_submitted( work ).deliver_later unless work.nil?
    status = ServiceClient::EntityIdClient.instance.metadatasync( work ) unless work.nil?
		redirect_to locally_hosted_work_url( id ), :flash => { :notice => "Thank you for your submission. You have finished this requirement for graduation." }
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
