require_dependency 'libraetd/lib/serviceclient/user_info_client'
require_dependency 'libraetd/lib/helpers/user_info'
require_dependency 'libraetd/lib/serviceclient/entity_id_client'

module Helpers

  class EtdHelper

    def self.process_inbound_sis_authorization( deposit_authorization )

      # lookup the user and create their account as necessary
      user, _ = lookup_or_create_user( deposit_authorization.who )
      if user.nil?
        return false
      end

      # determine if this is an update to an existing work
      work_source = "#{GenericWork::THESIS_SOURCE_SIS}:#{deposit_authorization.id}"
      existing = find_existing_work( work_source )
      if existing.present?
        puts "INFO: found existing work for this authorization (#{deposit_authorization.id})"
        # only apply updates to draft works
        if existing.is_draft?
          before = existing.title.present? ? existing.title[ 0 ] : ''
          if deposit_authorization.title != before
             existing.title = [ deposit_authorization.title ]
             existing.save!
             puts "INFO: updated work #{existing.id} title from: '#{before}' to '#{deposit_authorization.title}'"
          end
          return true
        else
          puts "ERROR: SIS update for a published work (#{existing.id}); ignoring"
          return false
        end
      end

      ok = true
      w = GenericWork.create!( title: [ deposit_authorization.title ] ) do |w|

        # generic work attributes
        w.apply_depositor_metadata( user )
        w.creator = user.email
        w.author_email = user.email
        w.author_first_name = deposit_authorization.first_name
        w.author_last_name = deposit_authorization.last_name
        w.author_institution = GenericWork::DEFAULT_INSTITUTION

        w.date_created = CurationConcerns::TimeService.time_in_utc.strftime( "%Y-%m-%d" )

        w.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        w.embargo_state = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        w.visibility_during_embargo = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        w.work_type = GenericWork::WORK_TYPE_THESIS
        w.draft = 'true'
        w.publisher = GenericWork::DEFAULT_PUBLISHER
        w.department = deposit_authorization.department
        w.degree = deposit_authorization.degree
        w.language = GenericWork::DEFAULT_LANGUAGE
        w.license = GenericWork::DEFAULT_LICENSE

        # where the authorization comes from
        w.work_source = work_source

      end

      status, id = ServiceClient::EntityIdClient.instance.newid( w )
      if ServiceClient::EntityIdClient.instance.ok?( status ) && id.present?
        w.identifier = id
        w.permanent_url = GenericWork.doi_url( id )
      else
        puts "ERROR: cannot mint DOI (#{status}). Using public view"
        w.identifier = nil
        w.permanent_url = Rails.application.routes.url_helpers.public_view_url( w )
      end
      ok = w.save

      # send the email if necessary
      ThesisMailers.sis_thesis_can_be_submitted( user.email, user.display_name, MAIL_SENDER ).deliver_later if ok
      return ok
    end

    def self.process_inbound_optional_authorization( deposit_request )

      # lookup the user and create their account as necessary
      user, extended_info = lookup_or_create_user( deposit_request.who )
      if user.nil?
        return false
      end

      # default values
      default_title = 'Enter your title here'

      ok = true
      w = GenericWork.create!( title: [ default_title ] ) do |w|

        # generic work attributes
        w.apply_depositor_metadata( user )
        w.creator = user.email
        w.author_email = user.email
        w.author_first_name = extended_info.first_name || 'First name'
        w.author_last_name = extended_info.last_name || 'Last name'
        w.author_institution = GenericWork::DEFAULT_INSTITUTION

        w.date_created = CurationConcerns::TimeService.time_in_utc.strftime( "%Y-%m-%d" )

        w.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        w.visibility_during_embargo = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        w.embargo_state = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        w.work_type = GenericWork::WORK_TYPE_THESIS
        w.draft = 'true'
        w.publisher = GenericWork::DEFAULT_PUBLISHER
        w.department = deposit_request.department
        w.degree = deposit_request.degree
        w.language = GenericWork::DEFAULT_LANGUAGE
        w.license = GenericWork::DEFAULT_LICENSE

        # where the authorization comes from
        w.work_source = "#{GenericWork::THESIS_SOURCE_OPTIONAL}:#{deposit_request.id}"

        # who requested it
        w.registrar_computing_id = deposit_request.requester unless deposit_request.requester.nil?
      end

      status, id = ServiceClient::EntityIdClient.instance.newid( w )
      if ServiceClient::EntityIdClient.instance.ok?( status ) && id.present?
          w.identifier = id
          w.permanent_url = GenericWork.doi_url( id )
      else
        puts "ERROR: cannot mint DOI (#{status}). Using public view"
        w.permanent_url = Rails.application.routes.url_helpers.public_view_url( w )
      end
      ok = w.save
      ThesisMailers.optional_thesis_can_be_submitted( user.email, user.display_name, MAIL_SENDER ).deliver_later if ok
      return ok
    end

    private

    #
    # look for a work that corresponds to the specified work source. This tells us that we have
    # previously created a placeholder ETD for the student
    #
    def self.find_existing_work( work_source )

      works = GenericWork.where( {work_source: work_source } )
      if works.present?
        return works.first
      end
      return nil

    end


    def self.lookup_or_create_user( cid )

      # lookup the user by computing id
      user_info = lookup_user( cid )
      if user_info.nil?
        puts "ERROR: cannot locate user info for #{cid}"
        return nil, nil
      end

      # locate the user and create the account if we cannot... cant create an ETD without an owner
      email = user_info.email
      email = User.email_from_cid( user_info.id ) if email.nil? || email.blank?
      user = User.find_by_email( email )
      user = create_user( user_info, email ) if user.nil?

      return user, user_info
    end

    def self.create_user( user_info, email )

      default_password = 'password'

      user = User.new( email: email,
                       password: default_password, password_confirmation: default_password,
                       display_name: user_info.display_name,
                       department: user_info.department.first,
                       office: user_info.office,
                       telephone: user_info.phone,
                       title: user_info.description )
      user.save!
      puts "INFO: created new account for #{user_info.id}"
      return( user )

    end

    def self.lookup_user( id )

      status, resp = ServiceClient::UserInfoClient.instance.get_by_id( id )
      if ServiceClient::UserInfoClient.instance.ok?( status )
        return Helpers::UserInfo.create( resp )
      end
      return nil

    end

  end

end

#
# end of file
#
