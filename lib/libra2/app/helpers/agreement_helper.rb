module AgreementHelper

  def deposit_agreement_url
    _, u = deposit_agreement
    return( u )
  end

  def deposit_agreement_type
     t, _ = deposit_agreement
     return( t )
  end

  private

  def deposit_agreement
    if current_user && current_user.title && current_user.title.match( /^Undergraduate/ )
      return 'Libra U.Va.-only Deposit License', 'http://www.library.virginia.edu/libra/open-access/libra-deposit-license/#uvaonly'
    end
    return 'Libra Deposit License for Student Theses and Dissertations', 'http://www.library.virginia.edu/libra/etds/etd-license'
  end
end
