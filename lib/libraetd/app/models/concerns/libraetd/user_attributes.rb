module Libra2::UserAttributes

  extend ActiveSupport::Concern

  # is the user an undergraduate
  def is_undergraduate?
    return false if title.nil?
    return title.match( /^Undergraduate/ )
  end

  # is the user an engineering student
  # Matches "Engineering" ignoring case
  def is_engineering?
    return false if department.nil?
    return department.match? /Engineering/i
  end

  def computing_id
    User.cid_from_email(self.email)
  end

  included do

     # extract the computing ID from the supplied email address; assumes computing_id@blablabla.bla
     def self.cid_from_email( em )
        return '' if em.nil? || em.empty?
        return em.split( "@" )[ 0 ]
     end

     def self.email_from_cid( cid )
       return '' if cid.nil? || cid.empty?
       return "#{cid}@virginia.edu"
     end

  end

end
