module Helpers

  #
  # helper class for the deposit authorization response
  #
  # deposit authorizations represent a required thesis deposit authorization
  #

  class DepositAuthorization

      attr_accessor :id
      attr_accessor :who
      attr_accessor :first_name
      attr_accessor :last_name
      attr_accessor :title
      attr_accessor :department
      attr_accessor :degree

      def initialize( json )
        @id = json['id'] || '0'
        @who = json[ 'computing_id'] || ''
        @first_name = json[ 'first_name'] || ''
        @last_name = json[ 'last_name'] || ''
        @title = json[ 'title'] || ''
        @department = json[ 'department'] || ''
        @degree = json[ 'degree'] || ''
      end

      def self.create( json )
         new( json )
      end
  end
end

#
# end of file
#
