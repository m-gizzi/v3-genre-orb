# frozen_string_literal: true

class BatchUpdatePlaylistsTrackDataJob
  include Sidekiq::Job

  def perform
    args = Playlist.pluck(:id).zip
    UpdatePlaylistTrackDataJob.perform_bulk(args)
  end
end
