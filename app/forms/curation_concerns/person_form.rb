class PersonForm
  include HydraEditor::Form

  self.model_class = 'Person'

  self.required_fields = []

  self.terms = [:first_name, :last_name]

  #def title
  #  model.foaf_name
  #end
end