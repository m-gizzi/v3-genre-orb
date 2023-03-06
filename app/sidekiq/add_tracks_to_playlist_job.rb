# frozen_string_literal: true

class AddTracksToPlaylistJob
  include Sidekiq::Job
  sidekiq_options queue: :spotify_api_calls

  def perform(playlist_id, track_ids)
    playlist = Playlist.find_by(id: playlist_id)
    tracks = Track.where(id: track_ids)

    playlist&.add_tracks!(tracks)
  end
end
