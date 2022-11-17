# frozen_string_literal: true

class BatchUpdateTrackDataJob
  include Sidekiq::Job

  def perform
    args = Playlist.ids.map { |id| [id, 'Playlist'] }
    # args += LikedSongsPlaylist.ids.map { |id| [id, 'LikedSongsPlaylist'] }

    UpdatePlaylistTrackDataBatchQueuingJob.perform_bulk(args)
  end
end
