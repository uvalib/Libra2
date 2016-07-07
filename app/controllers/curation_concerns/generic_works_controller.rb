module CurationConcerns

  class GenericWorksController < ApplicationController
    after_action :save_file_display_name
    before_action :set_requirements, only: [ :show ]
    before_action :is_me

    def is_me
      work = GenericWork.where({ id: params[:id] })
      if work.empty? || current_user.nil?
        render404()
      elsif !work[0].is_mine?(current_user.email)
        render404()
        end
    end

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

          # newly_uploaded_files_label = params['newly_uploaded_files_label']
          # if newly_uploaded_files_label.present?
          #   offset = previously_uploaded_files_label.present? ? previously_uploaded_files_label.length : 0
          #   newly_uploaded_files_label.each_with_index { |label, i|
          #     file_attributes = { title: [ label ]}
          #     actor = ::CurationConcerns::Actors::FileSetActor.new(file_sets[offset+i], current_user)
          #     actor.update_metadata(file_attributes) #TODO-PER: fix this if we change to delayed file upload.
          #   }
          # end
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
      if presenter.contributor.present? && presenter.contributor.length >= 4
        metadata = false if presenter.contributor[0].end_with?(": ")
        metadata = false if presenter.contributor[1].end_with?(": ")
        metadata = false if presenter.contributor[2].end_with?(": ")
        metadata = false if presenter.contributor[3].end_with?(": ")
      end
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
