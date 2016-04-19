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

      def initialize( json )
        @id = json['cid'] || '0'
        @display_name = json[ 'display_name'] || ''
        @first_name = json[ 'first_name'] || ''
        @initials = json[ 'initials'] || ''
        @last_name = json[ 'last_name'] || ''
        @description = json[ 'description'] || ''
        @department = json[ 'department'] || ''
      end

      def self.create( json )
         new( json )
      end
  end
end

#
# end of file
#
