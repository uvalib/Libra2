module CurationConcerns

  class GenericWorksController < ApplicationController
    after_action :save_file_display_name
    before_action :set_requirements, only: [ :show ]

    def save_file_display_name
      # TODO-PER: This is a hack to try to figure out how to save the file's display title. There is probably a better way to do this.
      if params['action'] == 'update'
        work = GenericWork.where({ id: params[:id] })
        if work.length > 0
          file_sets = work[0].file_sets
          previously_uploaded_files_label = params['previously_uploaded_files_label']
          if previously_uploaded_files_label.present?
            previously_uploaded_files_label.each_with_index { |label, i|
              file_attributes = { title: [ label ]}
              actor = ::CurationConcerns::Actors::FileSetActor.new(file_sets[i], current_user)
              actor.update_metadata(file_attributes)
            }
          end

          newly_uploaded_files_label = params['newly_uploaded_files_label']
          if newly_uploaded_files_label.present?
            offset = previously_uploaded_files_label.present? ? previously_uploaded_files_label.length : 0
            newly_uploaded_files_label.each_with_index { |label, i|
              file_attributes = { title: [ label ]}
              actor = ::CurationConcerns::Actors::FileSetActor.new(file_sets[offset+i], current_user)
              actor.update_metadata(file_attributes)
            }
          end
        end
      end
    end

    def set_requirements
      has_files = false
      if presenter.file_set_presenters.present?
        has_files = presenter.file_set_presenters.length > 0
      end
      metadata = true
      metadata = false if presenter.title.blank?
      metadata = false if presenter.author_first_name.blank?
      metadata = false if presenter.author_last_name.blank?
      metadata = false if presenter.department.blank?
      metadata = false if presenter.author_institution.blank?
      metadata = false if presenter.contributor.blank?
      metadata = false if presenter.description.blank?
      metadata = false if presenter.rights.blank?
      metadata = false if presenter.degree.blank?
      @requirements = {
          files: has_files,
          metadata: metadata
      }
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
  end
end
