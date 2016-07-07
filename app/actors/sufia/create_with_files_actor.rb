module Sufia
  # Creates a work and attaches files to the work
  class CreateWithFilesActor < CurationConcerns::Actors::AbstractActor
    def create(attributes)
      parse_parameters(attributes)
      validate_files && next_actor.create(attributes) && attach_files
    end

    def update(attributes)
      parse_parameters(attributes)
      validate_files && next_actor.update(attributes) && attach_files
    end

    protected
    def parse_parameters(attributes)
      uploaded_files = attributes.delete(:uploaded_files)
      uploaded_files = [] if uploaded_files.nil?
      ids = []
      labels = []
        uploaded_files.each { |uploaded_file|
          ids.push(uploaded_file['id'])
          labels.push(uploaded_file['label'])
        }
      self.uploaded_file_ids = ids
      self.uploaded_file_labels = labels
    end

      attr_reader :uploaded_file_ids
      def uploaded_file_ids=(input)
        @uploaded_file_ids = Array.wrap(input).select(&:present?)
      end

      attr_reader :uploaded_file_labels
      def uploaded_file_labels=(input)
        @uploaded_file_labels = Array.wrap(input).select(&:present?)
      end

      # ensure that the files we are given are owned by the depositor of the work
      def validate_files
        expected_user_id = user.id
        uploaded_files.each do |file|
          if file.user_id != expected_user_id
            Rails.logger.error "User #{user.user_key} attempted to ingest uploaded_file #{file.id}, but it belongs to a different user"
            return false
          end
        end
        true
      end

      # @return [TrueClass]
      def attach_files
        return true unless uploaded_files
        AttachFilesToWorkJob.perform_later(curation_concern, uploaded_files, uploaded_file_labels)
        true
      end

      # Fetch uploaded_files from the database
      def uploaded_files
        return [] if uploaded_file_ids.empty?
        @uploaded_files ||= UploadedFile.find(uploaded_file_ids)
      end
  end
end
