module ThesisHelper

  def render_active_theses
    render partial: 'my/theses_list'
  end

  def render_thesis_attribute(label, value)
    if value.kind_of?(Array)
      payload = []
      value.each { |v|
        payload.push(content_tag(:li, v, { class: "attribute" }))
      }
      payload = raw(payload.join("\n"))
    else
        payload = content_tag(:li, value, { class: "attribute" })
    end
    row = raw(content_tag(:th, label, {}) + content_tag(:td, raw("<ul class=\"tabular\">#{payload}</ul>")))
    return content_tag(:tr, row, {})
  end

  def requirement_class(requirements, type)
     klass = "incomplete"
     if requirements.present?
        klass = requirements[type] ? "complete" : "incomplete"
     end
     return klass
  end

  def pending_file_override(requirements, type, pending_file)
    if @pending_file_test.present?
      return "pending"
    else
      return requirement_class(requirements, type)
    end
  end

  def add_files_text(pending_file)
    if @pending_file_test.present?
      return "Add Files (upload in progress)"
    else
      return "Add Files"
    end
  end

  def proof_link(presenter, requirements)
    if proof_is_readonly(requirements)
      edit_polymorphic_path([main_app, presenter])
    else
      locally_hosted_work_url(presenter.solr_document.id)
    end
  end

  def link_if( condition, title, url )
    if condition == true
      return raw( "<a href=\"#{url}\">#{title}</a>" )
    else
      return raw( title )
    end
  end

  def proof_is_readonly(requirements)
     return !requirements[:files] || !requirements[:metadata]
  end

  def proof_tooltip(requirements)
     if requirements[:files] && requirements[:metadata]
        return "You have entered the required information. Click to continue the submission process."
     elsif requirements[:files]
        return "There are some required fields missing. Before continuing the submission process, click \"Edit\" to enter the missing data."
     elsif requirements[:metadata]
        return "You must upload at least one file to satisfy the requirements for submission. Click \"Edit\" to upload your files."
     else
        return "Before continuing the submission process, click \"Edit\" to enter all required fields and upload your files."
     end
  end

end
