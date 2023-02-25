# frozen_string_literal: true

class RemoveTracksFromPlaylistJob
  include Sidekiq::Job
  sidekiq_options queue: :spotify_api_calls

  def perform(playlist_id, track_ids)
    playlist = Playlist.find_by(id: playlist_id)
    tracks = Track.where(id: track_ids)

    playlist&.remove_tracks!(tracks)
  end
end
