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

      attr_accessor :accepted_at
      attr_accessor :approved_at
      attr_accessor :created_at
      attr_accessor :exported_at

      def initialize( json )
        @id = json['id'] || '0'
        @who = json[ 'computing_id'] || ''
        @first_name = json[ 'first_name'] || ''
        @last_name = json[ 'last_name'] || ''
        @title = json[ 'title'] || ''
        @department = json[ 'department'] || ''
        @degree = json[ 'degree'] || ''

        @accepted_at = json[ 'accepted_at'] || ''
        @approved_at = json[ 'approved_at'] || ''
        @created_at = json[ 'created_at'] || ''
        @exported_at = json[ 'exported_at'] || ''
      end

      def self.create( json )
         new( json )
      end
  end
end

#
# end of file
#
