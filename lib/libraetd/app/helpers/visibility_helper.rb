module VisibilityHelper

  def embargo_visibility_options( options = nil )
    options = [
       Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
       Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    ] if options.nil?

    options.map { |value| [ visibility_text(value), value ] }
  end

  def embargo_duration_options( document = nil )
    options = [
        GenericWork::EMBARGO_VALUE_6_MONTH,
        GenericWork::EMBARGO_VALUE_1_YEAR,
        GenericWork::EMBARGO_VALUE_2_YEAR,
        GenericWork::EMBARGO_VALUE_5_YEAR
    ]
    is_mfa = document && document.department == "Creative Writing - Graduate School of Arts and Sciences" &&
      document.degree == "MFA (Master of Fine Arts)"
    options << GenericWork::EMBARGO_VALUE_10_YEAR if is_mfa

    options.map { |value| [ duration_text(value), value ] }
  end

  def edit_link_if_draft(document)
    return edit_curation_concerns_generic_work_path(document) if document && document.is_draft?
    return curation_concerns_generic_work_path(document)
  end

  private

  def visibility_text( value )
    t("libra.visibility.#{value}.text", default: value )
  end

  def duration_text( value )
    t("libra.duration.#{value}.text", default: value )
  end

    def render_visibility_with_draft(document)
      if document.is_draft?
        return content_tag(:span, "Draft", { class: "label label-danger" })
      elsif is_engineering_embargo(document)
        return t("libra.visibility.embargo_engineering.label_html")
      elsif is_non_engineering_embargo(document)
        return t("libra.visibility.embargo.label_html")
      else
        return t("libra.visibility.open.label_html")
      end
    end
end
