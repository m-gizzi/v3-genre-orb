# frozen_string_literal: true

require 'has_spotify_client'

class UpdatePlaylistTrackDataBatchQueuingService < ApplicationService
  include HasSpotifyClient

  attr_reader :playlist, :track_data_import

  MAXIMUM_PLAYLIST_TRACKS_PER_JOB = {
    'Playlist' => 100,
    'LikedSongsPlaylist' => 50
  }.freeze

  def initialize(playlist)
    @playlist = playlist
    @track_data_import = playlist.track_data_imports.new
  end

  def call
    @track_data_import.save!
    playlist.sync_with_spotify!(rspotify_sync_object)
    offsets = determine_offsets

    args = offsets.map { |offset| [playlist.id, playlist.class.to_s, track_data_import.id, offset] }
    UpdatePlaylistTrackDataJob.perform_bulk(args)
  end

  private

  def rspotify_sync_object
    case playlist.class.to_s
    when 'Playlist'
      playlist.to_rspotify_playlist
    when 'LikedSongsPlaylist'
      rspotify_user = playlist.user.to_rspotify_user
      spotify_client.get_liked_tracks(rspotify_user)
    end
  end

  def determine_offsets
    0.step(playlist.song_count, MAXIMUM_PLAYLIST_TRACKS_PER_JOB[playlist.class.to_s])
  end
end
