module Libra2::UserAttributes

  extend ActiveSupport::Concern

  # is the user an undergraduate
  def is_undergraduate?
    return false if title.nil?
    return title.match( /^Undergraduate/ )
  end

  # is the user an engineering student
  def is_engineering?
    return false if department.nil?
    return department.match( /-?eng$/ )
  end

  # placeholder until we can do better
  def is_supervisor?
    return [ 'per4k@eservices.virginia.edu',
             'dpg3k@virginia.edu',
             'ecr2c@virginia.edu',
             'sah@virginia.edu' ].include? email
  end

  included do

     # extract the computing ID from the supplied email address; assumes computing_id@blablabla.bla
     def self.cid_from_email( em )
        return '' if em.nil? || em.empty?
        return em.split( "@" )[ 0 ]
     end
  end

end