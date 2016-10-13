module Libra2

  module OrcidBehavior

    extend ActiveSupport::Concern

    included do

      #
      # get the depositor's ORCID if possible
      #
      def my_orcid
        return 'unknown' if depositor.blank?
        user = ::User.find_by_user_key( depositor )
        return 'unknown' if user.nil?
        return user.orcid
      end
    end
  end
end
