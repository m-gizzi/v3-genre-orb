# frozen_string_literal: true

class UpdatePlaylistTrackDataJob
  include Sidekiq::Job

  def perform(playlist_id)
    playlist = Playlist.find_by(id: playlist_id)
    playlist&.update_track_data!
  end
end
