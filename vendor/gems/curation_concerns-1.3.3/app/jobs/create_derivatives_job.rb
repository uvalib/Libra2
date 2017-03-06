class CreateDerivativesJob < ActiveJob::Base
  queue_as CurationConcerns.config.ingest_queue_name

  # @param [FileSet] file_set
  # @param [String] file_id identifier for a Hydra::PCDM::File
  def perform(file_set, file_id)
    puts "==> #{file_set.id}: enter CreateDerivativesJob:perform file_set.id = #{file_set.id}, file_id = #{file_id}"
    return if file_set.video? && !CurationConcerns.config.enable_ffmpeg
    filename = CurationConcerns::WorkingDirectory.find_or_retrieve(file_id, file_set.id)
    puts "==> #{file_set.id}: filename = #{filename}"

    puts "==> #{file_set.id}: calling file_set.create_derivatives()"
    file_set.create_derivatives(filename)
    puts "==> #{file_set.id}: done"

    # Reload from Fedora and reindex for thumbnail and extracted text
    puts "==> #{file_set.id}: calling file_set.reload()"
    file_set.reload
    puts "==> #{file_set.id}: calling file_set.update_index()"
    file_set.update_index
    puts "==> #{file_set.id}: calling file_set.parent.update_index()" if parent_needs_reindex?(file_set)
    file_set.parent.update_index if parent_needs_reindex?(file_set)
    puts "==> #{file_set.id}: exit CreateDerivativesJob:perform"
  end

  # If this file_set is the thumbnail for the parent work,
  # then the parent also needs to be reindexed.
  def parent_needs_reindex?(file_set)
    return false unless file_set.parent
    file_set.parent.thumbnail_id == file_set.id
  end
end
