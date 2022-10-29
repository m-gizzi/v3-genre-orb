# frozen_string_literal: true

class BatchUpdateTrackDataJob
  include Sidekiq::Job

  def perform
    args = Playlist.ids.zip
    UpdatePlaylistTrackDataJob.perform_bulk(args)

    args = LikedSongsPlaylist.ids.zip
    UpdateLikedSongsTrackDataJob.perform_bulk(args)
  end
end
