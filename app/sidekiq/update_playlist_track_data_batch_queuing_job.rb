# frozen_string_literal: true

class UpdatePlaylistTrackDataBatchQueuingJob
  include Sidekiq::Job

  def perform(playlist_id, playlist_class)
    playlist = playlist_class.constantize.find_by(id: playlist_id)
    playlist&.batch_queue_track_data_update!
  end
end
