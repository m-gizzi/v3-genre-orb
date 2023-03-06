# frozen_string_literal: true

class SyncSmartPlaylistJob
  include Sidekiq::Job

  def perform(smart_playlist_id)
    smart_playlist = SmartPlaylist.find_by(id: smart_playlist_id)
    smart_playlist&.sync!
  end
end
