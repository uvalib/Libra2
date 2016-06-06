class PersonInput < MultiValueInput
	def input_type
		'multi_value'.freeze
	end

	def input(wrapper_options)
		@rendered_first_element = false
		input_html_classes.unshift('string')
		input_html_options[:name] ||= "#{object_name}[#{attribute_name}][]"

		ret = outer_wrapper do
			buffer_each(collection) do |value, index|
				inner_wrapper do
					build_field(value, index)
				end
			end
		end
		return content_tag(:div, "Enter your chair as the first advisor.", { class: "field_help" }) + raw(ret)
	end

	private

	def create_input(label, name, value, index, help_text = nil)
		els = []
		els.push(content_tag(:label, label, { for: "#{name}_#{index}" }))
		els.push("<br>")
		els.push(content_tag(:input, "", { class: "form-control", id: "generic_work_#{name}_#{index}", name: "generic_work[#{name}][]", value: value }))
		els.push(content_tag(:div, help_text, { class: "field_help" })) if help_text.present?
		return raw(els.join("\n"))
	end

	def build_field(value, index)
		els = []
		f = self.object
		computing_id = f[:contributor_computing_id][index]
		first_name = f[:contributor_first_name][index]
		last_name = f[:contributor_last_name][index]
		department = f[:contributor_department][index]
		institution = f[:contributor_institution][index]

		input = create_input("Computing ID", "contributor_computing_id", computing_id, index, "Enter a UVa Computing ID to automatically fill the remaining fields for this person.")
		# <input class="fieldselector" name="field_selectors[descMetadata][person_0_computing_id][][person]" rel="person_0_computing_id" type="hidden" value="0">
		# <input class="fieldselector" name="field_selectors[descMetadata][person_0_computing_id][]" rel="person_0_computing_id" type="hidden" value="computing_id">
		# <span class="editable-container field" id="person_0_computing_id-container">
		# <label for="person_0_computing_id">Computing ID</label>
		# <span class="field_help">U.Va. only. Entering a Computing ID will automatically fill the remaining fields for this author.</span>
		# <input class="editable-edit edit" id="person_0_computing_id" data-datastream-name="descMetadata" rel="person_0_computing_id" name="asset[descMetadata][person_0_computing_id][0]" value=""></span>
		row = content_tag(:div, content_tag(:div, input, { class: "computing_id"}), { class: "group-row"})
		els.push(row)

		input1 = create_input("First Name", "contributor_first_name", first_name, index)
		# <input class="fieldselector" name="field_selectors[descMetadata][person_0_first_name][][person]" rel="person_0_first_name" type="hidden" value="0">
		# <input class="fieldselector" name="field_selectors[descMetadata][person_0_first_name][]" rel="person_0_first_name" type="hidden" value="first_name">
		# <span class="editable-container field" id="person_0_first_name-container">
		# <label for="person_0_first_name">First Name</label>
		# <input class="editable-edit edit" id="person_0_first_name" data-datastream-name="descMetadata" rel="person_0_first_name" name="asset[descMetadata][person_0_first_name][0]" value=""></span>
		input1 = content_tag(:div, input1, { class: "name_first"})

		input2 = create_input("Department", "contributor_department", department, index)
		# <input class="fieldselector" name="field_selectors[descMetadata][person_0_description][][person]" rel="person_0_description" type="hidden" value="0">
		# <input class="fieldselector" name="field_selectors[descMetadata][person_0_description][]" rel="person_0_description" type="hidden" value="description">
		# <span class="editable-container field" id="person_0_description-container">
		# <label for="person_0_description">Department</label><input class="editable-edit edit" id="person_0_description" data-datastream-name="descMetadata" rel="person_0_description" name="asset[descMetadata][person_0_description][0]" value=""></span>
		input2 = content_tag(:div, input2, { class: "department"})

		row = content_tag(:div, raw(input1 + input2), { class: "group-row"})
		els.push(row)

		input1 = create_input("Last Name", "contributor_last_name", last_name, index)
		#  <input class="fieldselector" name="field_selectors[descMetadata][person_0_last_name][][person]" rel="person_0_last_name" type="hidden" value="0">
		# <input class="fieldselector" name="field_selectors[descMetadata][person_0_last_name][]" rel="person_0_last_name" type="hidden" value="last_name">
		# <span class="editable-container field" id="person_0_last_name-container">
		# <label for="person_0_last_name">Last Name</label>
		# <input class="editable-edit edit" id="person_0_last_name" data-datastream-name="descMetadata" rel="person_0_last_name" name="asset[descMetadata][person_0_last_name][0]" value=""></span>
		input1 = content_tag(:div, input1, { class: "name_last"})

		input2 = create_input("Institution", "contributor_institution", institution, index)
		#  <input class="fieldselector" name="field_selectors[descMetadata][person_0_institution][][person]" rel="person_0_institution" type="hidden" value="0">
		# <input class="fieldselector" name="field_selectors[descMetadata][person_0_institution][]" rel="person_0_institution" type="hidden" value="institution"><span class="editable-container field" id="person_0_institution-container">
		# <label for="person_0_institution">Institution</label>
		# <input class="editable-edit edit" id="person_0_institution" data-datastream-name="descMetadata" rel="person_0_institution" name="asset[descMetadata][person_0_institution][0]" value=""></span>
		input2 = content_tag(:div, input2, { class: "affiliation"})
		row = content_tag(:div, raw(input1 + input2), { class: "group-row"})
		els.push(row)

		els.push(content_tag(:div, "", { style: "clear: both;"}))

		return content_tag(:div, raw(els.join("\n")), { class: "person-input" })
	end
end
