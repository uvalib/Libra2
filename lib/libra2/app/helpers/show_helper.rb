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

  def show_line(presenter, field_name, label, required)
    tr = presenter.attribute_to_html(field_name, label: label, include_empty: true, catalog_search_link: false )
    if required
      tr = show_wrap_required(tr)
    end
    return tr
  end
end
