# frozen_string_literal: true

class BatchSyncPlaylistJob
  include Sidekiq::Job

  # Too much RAM usage
  # Maybe slow down to reduce errors?
  # Figure out playlists that came out over 10000 tracks
  # Figure out duplicate additions
  def perform
    args = SmartPlaylist.ids.zip
    SyncSmartPlaylistJob.perform_bulk(args)
  end
end
