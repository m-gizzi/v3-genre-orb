# frozen_string_literal: true

class BatchUpdateTrackDataJob
  include Sidekiq::Job

  def perform
    ids = Playlist.ids
    args = ids.map { |id| [id, 'asynchronous'] }
    UpdatePlaylistTrackDataJob.perform_bulk(args)

    ids = LikedSongsPlaylist.ids
    args = ids.map { |id| [id, 'asynchronous'] }
    UpdateLikedSongsTrackDataJob.perform_bulk(args)
  end
end
