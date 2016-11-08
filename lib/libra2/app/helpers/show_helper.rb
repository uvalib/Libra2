module ShowHelper

  def show_wrap_required(tr)
    # This is a hack to add a class to blank required fields on the show page.
    # The input is the output of Sufia's formatting of a table row.
    # If the field is blank (that is there is nothing in the resultant <ul> element),
    # then add the class to the outer <tr>.
    # Note that this will probably break when Sufia changes it's output format.
    if tr.include?("<ul class='tabular'></ul>")
      tr = tr.gsub("<tr>", "<tr class='required-field'>")
      return raw(tr)
    end
      return tr
  end

  def show_contributor_required(tr)
    tr = show_wrap_required(tr)
    missing = false
    missing = true if tr.include?('<span itemprop="name">First Name: </span>')
    missing = true if tr.include?('<span itemprop="name">Last Name: </span>')
    missing = true if tr.include?('<span itemprop="name">Department: </span>')
    missing = true if tr.include?('<span itemprop="name">Institution: </span>')
    if missing
      tr = tr.gsub("<tr>", "<tr class='required-field'>")
      return raw(tr)
    end
    return tr
  end

  def keep_new_lines(tr)
    return raw(tr.gsub("\n", "<br>"))
  end

  def show_line(presenter, field_name, label, required, options )
    tr = presenter.attribute_to_html(field_name, options.merge( { label: label } ) )
    if field_name == :contributor
      tr = show_contributor_required(tr)
    elsif required
      tr = show_wrap_required(tr)
    end
    if field_name == :description
      tr = keep_new_lines(tr)
    end
    return tr
  end

    def show_visibility_line(state, period)
      th = content_tag(:th, "Visibility", {})
      if state == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        state_str = t("libra.visibility.open.text")
      elsif state == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        state_str = t("libra.visibility.embargo_engineering.text")
        period = period[0] if period.kind_of?(Array)
        period = GenericWork.displayable_embargo_period( period )
        state_str = "#{state_str} until #{period} from submitting this thesis"
      elsif state == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
        state_str = t("libra.visibility.embargo.text")
        period = period[0] if period.kind_of?(Array)
        period = GenericWork.displayable_embargo_period( period )
        state_str = "#{state_str} until #{period} from submitting this thesis"
      end
      state_el = content_tag(:li, state_str, { class: "attribute embargo_state" })
      ul = content_tag(:ul, state_el, { class: "tabular"})
      td = content_tag(:td, ul, {})
      return content_tag(:tr, raw(th + td))
    end
end
