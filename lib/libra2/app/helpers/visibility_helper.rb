module VisibilityHelper

  def post_embargo_visibility_options
    options = [
       Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
       Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    ]

    options.map { |value| [ visibility_text(value), value ] }
  end

  def embargo_duration_options
    options = [
        GenericWork::EMBARGO_VALUE_6_MONTH,
        GenericWork::EMBARGO_VALUE_1_YEAR,
        GenericWork::EMBARGO_VALUE_2_YEAR,
        GenericWork::EMBARGO_VALUE_5_YEAR
    ]
    options.map { |value| [ duration_text(value), value ] }
  end

  private

  def visibility_text( value )
    t("libra.visibility.#{value}.text", default: value )
  end

  def duration_text( value )
    t("libra.duration.#{value}.text", default: value )
  end

end
