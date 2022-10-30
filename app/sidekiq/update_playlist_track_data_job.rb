# frozen_string_literal: true

class UpdatePlaylistTrackDataJob
  include Sidekiq::Job

  def perform(playlist_id, self_queuing = nil, track_data_id = nil, offset = 0)
    playlist = Playlist.find_by(id: playlist_id)
    track_data = TrackData.find_by(id: track_data_id)
    playlist&.update_track_data!(track_data:, offset:, self_queuing:)
  end
end
