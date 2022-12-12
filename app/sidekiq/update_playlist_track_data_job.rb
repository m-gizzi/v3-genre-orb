# frozen_string_literal: true

class UpdatePlaylistTrackDataJob
  include Sidekiq::Job
  sidekiq_options queue: :spotify_api_calls

  def perform(playlist_id, playlist_class, track_data_id, offset = 0)
    playlist = playlist_class.constantize.find_by(id: playlist_id)
    track_data = TrackData.find_by(id: track_data_id)

    playlist&.update_track_data!(track_data, offset:)
  end
end
