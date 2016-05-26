module Helpers

  #
  # helper class for the deposit request response
  #
  # deposit requests represent an optional thesis deposit authorization
  #

  class DepositRequest

      attr_accessor :id
      attr_accessor :requester
      attr_accessor :who
      attr_accessor :department
      attr_accessor :degree

      def initialize( json )
        @id = json['id'] || '0'
        @requester = json[ 'requester'] || ''
        @who = json[ 'for'] || ''
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
