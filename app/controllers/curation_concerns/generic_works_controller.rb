module CurationConcerns

  class GenericWorksController < ApplicationController
    after_action :save_file_display_name

    def save_file_display_name
      # TODO-PER: This is a hack to try to figure out how to save the file's display title. There is probably a better way to do this.
      if params['action'] == 'update'
        work = GenericWork.where({ id: params[:id] })
        if work.length > 0
          file_sets = work[0].file_sets
          previously_uploaded_files_label = params['previously_uploaded_files_label']
          previously_uploaded_files_label.each_with_index { |label, i|
            file_attributes = { title: [ label ]}
            actor = ::CurationConcerns::Actors::FileSetActor.new(file_sets[i], current_user)
            actor.update_metadata(file_attributes)
          }
        end
      end
    end

    include CurationConcerns::CurationConcernController

    # Adds Sufia behaviors to the controller.
    include Sufia::WorksControllerBehavior

    # Adds identifier behavior to the controller.
    include Libra2::CreateIdentifierBehavior

    # Adds license application behavior to the controller.
    include Libra2::ApplyLicenseBehavior

    self.curation_concern_type = GenericWork

    # use our custom presenter
    self.show_presenter = CustomGenericWorkPresenter

    # use our edit form
    #self.form_class = ::CurationConcerns::GenericWorkForm
  end
end
