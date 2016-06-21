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
		return content_tag(:div, "Enter your committee chair as the first advisor.", { class: "field_help" }) + raw(ret)
	end

	private

	def create_input(label, name, value, index, help_text = nil)
		els = []
		els.push(content_tag(:label, label, { for: "#{name}_#{index}" }))
		els.push("<br>")
		els.push(content_tag(:input, "", { class: "form-control #{name}", id: "contributor_#{name}_#{index}", name: "contributor[#{name}][]", value: value, "data-index" => index }))
		els.push(content_tag(:div, help_text, { class: "field_help" })) if help_text.present?
		return raw(els.join("\n"))
	end

	def build_field(value, index)
		els = []
		# f = self.object
		# computing_id = f[:contributor_computing_id][index]
		# first_name = f[:contributor_first_name][index]
		# last_name = f[:contributor_last_name][index]
		# department = f[:contributor_department][index]
		# institution = f[:contributor_institution][index]

		value = "" if value.nil?
		arr = value.split("\n")
		computing_id = arr[0]
		first_name = arr.length > 1 ? arr[1] : ""
		last_name = arr.length > 2 ? arr[2] : ""
		department = arr.length > 3 ? arr[3] : ""
		institution = arr.length > 4 ? arr[4] : ""

		input = create_input("Computing ID", "contributor_computing_id", computing_id, index, "Enter a UVA Computing ID to automatically fill the remaining fields for this person.")
		contributor = content_tag(:input, "", { type: 'hidden', name: "generic_work[contributor][]", value: value, "data-index" => index, class: "contributor" })
		row = content_tag(:div, content_tag(:div, raw(input + contributor), { class: "computing_id"}), { class: "group-row"})
		els.push(row)

		input1 = create_input("First Name", "contributor_first_name", first_name, index)
		input1 = content_tag(:div, input1, { class: "name_first"})

		input2 = create_input("Last Name", "contributor_last_name", last_name, index)
		input2 = content_tag(:div, input2, { class: "name_last"})

		row = content_tag(:div, raw(input1 + input2), { class: "group-row"})
		els.push(row)

		input1 = create_input("Department", "contributor_department", department, index)
		input1 = content_tag(:div, input1, { class: "department"})

		input2 = create_input("Institution", "contributor_institution", institution, index)
		input2 = content_tag(:div, input2, { class: "affiliation"})
		row = content_tag(:div, raw(input1 + input2), { class: "group-row"})
		els.push(row)

		els.push(content_tag(:div, "", { style: "clear: both;"}))

		return content_tag(:div, raw(els.join("\n")), { class: "person-input" })
	end
end
