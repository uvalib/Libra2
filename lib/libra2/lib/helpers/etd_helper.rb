require_dependency 'libra2/lib/serviceclient/user_info_client'
require_dependency 'libra2/lib/helpers/user_info'

module Helpers

  class EtdHelper

    def self.new_etd_from_deposit_request( dr )

      default_email_domain = 'virginia.edu'

      # locate the user and create the account if we cannot... cant create an ETD without an owner
      email = "#{dr.who}@#{default_email_domain}"
      user = User.find_by_email( email )
      user = create_user( dr.who, email ) if user.nil?

      if user.nil?
        puts "Cannot locate user info for #{dr.who}"
        return false
      end

      # default values
      default_title = 'Enter your title here'
      default_description = 'Enter your description here'
      default_contributor = 'Your contributors here'
      default_rights = 'Your rights assignments here'
      default_license = 'Your license terms here'

      GenericWork.create!( title: [ default_title ] ) do |w|

        # generic work attributes
        w.apply_depositor_metadata( user )
        w.creator = email
        w.date_created = CurationConcerns::TimeService.time_in_utc.strftime( "%Y/%m/%d" )

        w.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        w.description = default_description
        w.work_type = GenericWork::WORK_TYPE_THESIS
        w.draft = 'true'
        w.publisher = GenericWork::DEFAULT_PUBLISHER
        w.department = dr.department
        w.degree = dr.degree

        w.contributor << default_contributor
        w.rights << default_rights
        w.license << default_license

        status, id = ServiceClient::EntityIdClient.instance.newid( w )
        if ServiceClient::EntityIdClient.instance.ok?( status )
           w.identifier = id
        else
          puts "Cannot mint DOI (#{status})"
          return false
        end

      end
      return true
    end

    private

    def self.create_user( id, email )

      default_password = 'password'

      status, resp = ServiceClient::UserInfoClient.instance.get_by_id( id )
      if ServiceClient::UserInfoClient.instance.ok?( status )
        info = Helpers::UserInfo.create( resp )

        user = User.new( email: email,
                         password: default_password, password_confirmation: default_password,
                         display_name: info.display_name,
                         title: "#{info.description}, #{info.department}" )
        user.save!
        puts "Created new account for #{id}"
        return( user )
      end
      return nil

    end

  end

end

#
# end of file
#