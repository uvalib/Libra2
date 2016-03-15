module Libra2

  #
  # helper class for the deposit request response
  #

   class DepositRequest

      attr_accessor :id
      attr_accessor :requester
      attr_accessor :who
      attr_accessor :school
      attr_accessor :degree

      def initialize( json )
        @id = json['id'] || '0'
        @requester = json[ 'requester'] || ''
        @who = json[ 'for'] || ''
        @school = json[ 'school'] || ''
        @degree = json[ 'degree'] || ''
      end

      def self.create( json )
         new( json )
      end
  end
end
