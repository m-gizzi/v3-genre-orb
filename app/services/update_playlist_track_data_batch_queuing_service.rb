# frozen_string_literal: true

class UpdatePlaylistTrackDataBatchQueuingService < ApplicationService
  MAXIMUM_PLAYLIST_TRACKS_PER_JOB = 100

  attr_reader :playlist, :track_data

  def initialize(playlist)
    @playlist = playlist
    @track_data = playlist.track_data.create!
  end

  def call
    rspotify_playlist = playlist.to_rspotify_playlist
    playlist.sync_with_spotify!(rspotify_playlist)

    offsets = 0.step(rspotify_playlist.total, MAXIMUM_PLAYLIST_TRACKS_PER_JOB)

    args = offsets.map { |offset| [playlist.id, playlist.class.to_s, nil, track_data.id, offset] }
    UpdatePlaylistTrackDataJob.perform_bulk(args)
  end
end
