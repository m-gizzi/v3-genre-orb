# frozen_string_literal: true

class BatchUpdateTrackDataJob
  include Sidekiq::Job

  def perform
    ids = Playlist.ids
    args = ids.map { |id| [id, Playlist.to_s, 'asynchronous'] }
    UpdatePlaylistTrackDataJob.perform_bulk(args)

    ids = LikedSongsPlaylist.ids
    args = ids.map { |id| [id, LikedSongsPlaylist.to_s, 'asynchronous'] }
    UpdatePlaylistTrackDataJob.perform_bulk(args)
  end
end
