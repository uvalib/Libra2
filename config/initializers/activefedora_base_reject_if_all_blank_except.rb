ActiveFedora::Base.class_eval do
  # returns true of all fields are blank except the ones passed in
  # eg: 'accepts_nested_attributes_for :children, except: all_blank_except(:ignored)'
  #
  def self.all_blank_except(*except_fields)
    proc {|attributes| attributes.except(*except_fields).all? {|k,v| k == '_destroy' || v.blank? } }
  end
end
