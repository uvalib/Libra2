# Libra Thesis
# This is the base class for all flavors of thesis: dissertation, masters,
# 4th year, class, etc.
# It is derived from Sufia's GenericWork in order to pick up all the behaviors
# associated with a GenericWork and be treated throughout the system as a
# GenericWork having the standard Sufia capabilities.
# This class extends that Sufia behavior for specific qualities that are
# required for Libra.

class Thesis < GenericWork
  #
  # CustomMetadata
  #
  # Thesis has a draft property which is either true or false.
  # When true, the thesis is not complete.
  # When false, the thesis is complete and has been submitted as final to the
  # finalization authority (SIS or class instructor, etc.).
  property :draft, predicate: ::RDF::URI('http://example.org/terms/draft'),
                   multiple: false do |index|
    index.as :stored_searchable
  end

end
