module Libra2

  class EtdHelper

    def self.new_etd_from_deposit_request( dr )

      default_email_domain = "virginia.edu"

      # determine the user and return if we cannot... cant create without an owner
      email = "#{dr.who}@#{default_email_domain}"
      user = User.find_by_email( email )
      if user.nil?
        puts "Cannot locate user #{email}"
        return false
      end

      title = 'Enter your Thesis Title Here'

      GenericWork.create!( title: [ title ] ) do |w|

        # generic work attributes
        w.apply_depositor_metadata( user )
        w.creator = email
        w.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        w.work_type = GenericWork::WORK_TYPE_THESIS
        w.publisher = GenericWork::DEFAULT_PUBLISHER
        w.department = dr.department
        w.degree = dr.degree

        status, id = Libra2::EntityIdClient.instance.newid( w )
        if Libra2::EntityIdClient.instance.ok?( status )
        w.identifier = id
        else
          puts "Cannot mint DOI (#{status})"
          return false
        end

      end
      return true
    end

  end

end

#
# end of file
#