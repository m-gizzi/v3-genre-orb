# frozen_string_literal: true

class UpdateLikedSongsTrackDataJob
  include Sidekiq::Job

  def perform(liked_songs_playlist_id)
    liked_songs_playlist = LikedSongsPlaylist.find_by(id: liked_songs_playlist_id)
    liked_songs_playlist&.update_track_data!
  end
end
