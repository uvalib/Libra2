module LanguageService
  mattr_accessor :authority
  self.authority = Qa::Authorities::Local.subauthority_for('languages')

  def self.select_active_options
    active_elements.map { |e| [e[:label], e[:id]] }
  end

  def self.label(id)
    authority.find(id).fetch('term')
  end

  def self.active_elements
    authority.all.select { |e| authority.find(e[:id])[:active] }
  end
end
