require_dependency 'libra2/lib/serviceclient/user_info_client'
require_dependency 'libra2/lib/helpers/user_info'

module Helpers

  class EtdHelper

    @default_email_domain = 'virginia.edu'

    def self.new_etd_from_sis_request( deposit_authorization )

      # lookup the user by computing id
      user_info = lookup_user( deposit_authorization.who )
      if user_info.nil?
        puts "Cannot locate user info for #{deposit_authorization.who}"
        return false
      end

      # locate the user and create the account if we cannot... cant create an ETD without an owner
      email = user_info.email
      email = "#{user_info.id}@#{@default_email_domain}" if email.nil? || email.blank?
      user = User.find_by_email( email )
      user = create_user( user_info, email ) if user.nil?

      ok = true
      GenericWork.create!( title: [ deposit_authorization.title ] ) do |w|

        # generic work attributes
        w.apply_depositor_metadata( user )
        w.creator = email
        w.author_email = email
        w.author_first_name = deposit_authorization.first_name
        w.author_last_name = deposit_authorization.last_name
        w.author_institution = GenericWork::DEFAULT_INSTITUTION

        w.date_created = CurationConcerns::TimeService.time_in_utc.strftime( "%Y/%m/%d" )

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
        w.work_source = "#{GenericWork::THESIS_SOURCE_SIS}:#{deposit_authorization.id}"

        status, id = ServiceClient::EntityIdClient.instance.newid( w )
        if ServiceClient::EntityIdClient.instance.ok?( status )
          w.identifier = id
          w.permanent_url = w.doi_url( id )
        else
          puts "Cannot mint DOI (#{status})"
          ok = false
        end

      end
      return ok
    end

    def self.new_etd_from_deposit_request( deposit_request )

      # lookup the user by computing id
      user_info = lookup_user( deposit_request.who )
      if user_info.nil?
        puts "Cannot locate user info for #{deposit_request.who}"
        return false
      end

      # locate the user and create the account if we cannot... cant create an ETD without an owner
      email = user_info.email
      email = "#{user_info.id}@#{@default_email_domain}" if email.nil? || email.blank?
      user = User.find_by_email( email )
      user = create_user( user_info, email ) if user.nil?

      # default values
      default_title = 'Enter your title here'

      ok = true
      GenericWork.create!( title: [ default_title ] ) do |w|

        # generic work attributes
        w.apply_depositor_metadata( user )
        w.creator = email
        w.author_email = email
        w.author_first_name = user_info.first_name || 'First name'
        w.author_last_name = user_info.last_name || 'Last name'
        w.author_institution = GenericWork::DEFAULT_INSTITUTION

        w.date_created = CurationConcerns::TimeService.time_in_utc.strftime( "%Y/%m/%d" )

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

        status, id = ServiceClient::EntityIdClient.instance.newid( w )
        if ServiceClient::EntityIdClient.instance.ok?( status )
           w.identifier = id
           w.permanent_url = w.doi_url( id )
        else
          puts "Cannot mint DOI (#{status})"
          ok = false
        end

      end
      return ok
    end

    private

    def self.create_user( user_info, email )

      default_password = 'password'

      user = User.new( email: email,
                       password: default_password, password_confirmation: default_password,
                       display_name: user_info.display_name,
                       department: user_info.department,
                       office: user_info.office,
                       telephone: user_info.phone,
                       title: user_info.description )
      user.save!
      puts "Created new account for #{user_info.id}"
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