# frozen_string_literal: true

class AddTracksToPlaylistJob
  include Sidekiq::Job

  def perform(playlist_id, track_uris)
    playlist = Playlist.find_by(id: playlist_id)
    AddTracksToPlaylistService.call(playlist, track_uris)
  end
end
