class Person < ActiveFedora::Base

  #include StoredInline

  #self.human_readable_type = 'Person'

  type ::RDF::FOAF.Person

  property :first_name, predicate: ::RDF::Vocab::FOAF.firstName, multiple: false do |index|
    index.as :stored_searchable
  end

  property :last_name, predicate: ::RDF::Vocab::FOAF.lastName, multiple: false do |index|
    index.as :stored_searchable
  end


end