# frozen_string_literal: true

class UpdateLikedSongsTrackDataJob
  include Sidekiq::Job

  def perform(liked_songs_playlist_id, self_queuing = nil, track_data_id = nil, offset = 0)
    liked_songs_playlist = LikedSongsPlaylist.find_by(id: liked_songs_playlist_id)
    track_data = TrackData.find_by(id: track_data_id)
    liked_songs_playlist&.update_track_data!(track_data:, offset:, self_queuing:)
  end
end
