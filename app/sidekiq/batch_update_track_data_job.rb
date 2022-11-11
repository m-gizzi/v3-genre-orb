# frozen_string_literal: true

class BatchUpdateTrackDataJob
  include Sidekiq::Job

  def perform
    args = Playlist.ids.map { |id| [id, 'Playlist', 'asynchronous'] }
    args += LikedSongsPlaylist.ids.map { |id| [id, 'LikedSongsPlaylist', 'asynchronous'] }

    UpdatePlaylistTrackDataJob.perform_bulk(args)
  end
end
