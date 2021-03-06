require_dependency 'libraetd/lib/helpers/etd_helper'

class SubmissionController < ApplicationController

  include AuthenticationHelper
  include UrlHelper
  include ServiceHelper
  include StatisticsHelper
  include WorkHelper

  #skip_before_action :require_auth, only: [ 'public_view' ]
  before_action :authenticate_user!, only: [ 'submit']
  layout "public"

  def public_view
    @id = params[:id]
    @work = get_generic_work( @id )

    @can_view = can_view(@work)
    if @can_view
      @is_preview = @work.is_draft?
      if !@is_preview # on the public page, there shouldn't be the the concept of logging in.
        @hide_login_controls = true
      end
      set_debugging_override()
      @files = get_file_sets(@work)

      # save work view statistics
      record_work_view_event( @work.id ) if @is_preview == false
    else
      render404public()
    end
  end

  def submit
    id = params[:id]
    work = get_generic_work( id )

    if work.present?

      work.draft = 'false'
      if work.embargo_state != Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC &&
          work.embargo_period != GenericWork::EMBARGO_VALUE_CUSTOM
        end_date = GenericWork.calculate_embargo_release_date( work.embargo_period )
        work.embargo_end_date = DateTime.new(end_date.year, end_date.month, end_date.day)
      end

      # set the publication date
      work.date_published = Time.zone.today.strftime( "%Y-%m-%d" )

      # save the changes
      work.save!

      # update the DOI service with the completed metadata
      update_doi_metadata(work)

      # update SIS as necessary
      update_submitted_state(work)

      # create/update the ORCID entry
      OrcidSyncJob.perform_later work.id, current_user.id

      # PER: All actual work is done before the emails are sent in case the email system crashes again.

      # send the author email that they have successfully completed things
      send_author_email(work)

      # send the registrar email that they have successfully completed things
      send_registrar_email(work)
    end

    notice = if work.identifier
      "Thank you for submitting your thesis. Be sure to make note of and refer to the Persistent Link when you refer to this work."
    else
      "Thank you for submitting your thesis. The Persistent Link could not be generated at this time. Check back later for the permananent URL."
    end

    redirect_to locally_hosted_work_url( id ), :flash => { :notice => notice }
  end

  def unpublish
    if ENV['ENABLE_TEST_FEATURES'].present?
      id = params[:id]
      work = get_generic_work( id )
      if work.present?
        work.draft = 'true'
        work.save!
      end
      redirect_to locally_hosted_work_url( id )
    end
  end

  private

  # send the author email that they have successfully completed things
  def send_author_email( work )

    return if work.nil?
    author = Helpers::EtdHelper::lookup_user( User.cid_from_email( work.creator ) )
    return if author.nil?

    # send the email
    ThesisMailers.thesis_submitted_author( work, author.display_name, MAIL_SENDER ).deliver_later

  end

  # send the registrar email that the student has successfully completed things
  def send_registrar_email( work )

    return if work.nil?

    # do nothing for SIS work
    return if work.is_sis_thesis?

    # do nothing if the registrar is blank
    return if work.registrar_computing_id.blank?

    # lookup the registrar info and return if we cannot find them
    registrar = Helpers::EtdHelper::lookup_user( work.registrar_computing_id )
    return if registrar.nil?

    # lookup author information
    author_id = User.cid_from_email( work.creator )
    author = Helpers::EtdHelper::lookup_user( author_id )
    author_name = author.nil? ? author_id : author.display_name

    # send the email
    ThesisMailers.thesis_submitted_registrar( work,
                                             author_name,
                                             registrar.display_name,
                                             registrar.email,
                                             MAIL_SENDER ).deliver_later

  end

  def can_view(work)

    # can view if the work exists and is published, or if it is draft and the owner is logged in.

    # no work, no access
    if work.nil?
      puts "==> work is undefined; view access is DENIED"
      return false
    end

    # this work is owned by the current user regardless of visibility
    if current_user.present? && work.is_mine?( current_user.email )
      puts "==> work is user owned; view access is GRANTED"
      return true
    end

    # if this work has NOT been published.
    if work.is_draft?
      puts "==> work is draft; view access is DENIED"
      return false
    end

    puts "==> work is published; view access is GRANTED"
    return true
  end

  def get_file_sets(work)
    show_files = view_context.allow_file_access(work)
    return [] if !show_files
    file_sets = work.file_sets
    files = []
    file_sets.each { |file|
      # ensure the title on the public page is not blank
      title = file.title.join(" ")
      title = file.label if title.blank?
      title = 'UNKNOWN' if title.blank?

      files.push({
        title: title,
        location: download_path(file),
        date: file.date_uploaded,
        id: file.id
      })
    }
    # ensure they are sorted in upload date order so the oldest is listed first
    files = files.sort { |a,b|
      a[:date] <=> b[:date]
    }

    return files
  end
end
