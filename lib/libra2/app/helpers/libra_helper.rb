module LibraHelper

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

  def deposit_agreement_url
    if current_user && current_user.title && current_user.title.match( /^Undergraduate/ )
      return 'http://www.library.virginia.edu/libra/open-access/libra-deposit-license/#uvaonly'
    end
    return 'http://www.library.virginia.edu/libra/etds/etd-license'
  end

end
