# frozen_string_literal: true

class RemoveTracksFromPlaylistJob
  include Sidekiq::Job
  sidekiq_options queue: :spotify_api_calls

  def perform(playlist_id, track_uris)
    playlist = Playlist.find_by(id: playlist_id)
    RemoveTracksFromPlaylistService.call(playlist, track_uris)
  end
end
