module Helpers

  #
  # helper class for the user info response
  #

   class UserInfo

      attr_accessor :id
      attr_accessor :display_name
      attr_accessor :first_name
      attr_accessor :initials
      attr_accessor :last_name
      attr_accessor :description
      attr_accessor :department
      attr_accessor :title
      attr_accessor :office
      attr_accessor :phone
      attr_accessor :email
      attr_accessor :private

      def initialize( json )
        @id = json['cid'] || '0'
        @display_name = json[ 'display_name'] || ''
        @first_name = json[ 'first_name'] || ''
        @initials = json[ 'initials'] || ''
        @last_name = json[ 'last_name'] || ''
        @description = json[ 'description'] ? json['description'].first : ''
        @department = json[ 'department'] ? json['department'].first : ''
        @title = json[ 'title'] ? json['title'].first : ''
        @office = json[ 'office'] ? json['office'].first : ''
        @phone = json[ 'phone'] ? json['phone'].first : ''
        @email = json[ 'email'] || ''

        # we have had some problems here; make sure all emails are lower case
        @email = @email.downcase
        @private = json[ 'private'] || ''
      end

      def self.create( json )
         new( json )
      end
  end
end

#
# end of file
#
