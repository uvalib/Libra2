module Libra2::UserAttributes

  extend ActiveSupport::Concern

  # is the user an undergraduate
  def is_undergraduate?
    return false if title.nil?
    return title.match( /^Undergraduate/ )
  end

  # is the user an engineering student
  def is_engineering?
    return false
  end

end