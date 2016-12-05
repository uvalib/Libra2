module ApplyLicenseBehavior
    extend ActiveSupport::Concern

    include AgreementHelper

    included do
      before_action :apply_license, only: [:update]
    end

    private

    # Apply the license wording as necessary
    def apply_license

      # has the user just accepted the license for the first time?
      if params[ :agreement ].blank? == false && params.fetch( :agreement ) == '1'
      #  curation_concern.license = deposit_agreement_type
        params[:generic_work][:license] = deposit_agreement_type( )
      end
    end

end
