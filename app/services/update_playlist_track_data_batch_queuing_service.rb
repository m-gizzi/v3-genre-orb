# frozen_string_literal: true

require 'has_spotify_client'

class UpdatePlaylistTrackDataBatchQueuingService < ApplicationService
  include HasSpotifyClient

  MAXIMUM_PLAYLIST_TRACKS_PER_JOB = 100

  attr_reader :playlist, :track_data

  def initialize(playlist)
    @playlist = playlist
    @track_data = playlist.track_data.create!
  end

  def call
    playlist.sync_with_spotify!(rspotify_sync_object)
    offsets = 0.step(playlist.song_count, MAXIMUM_PLAYLIST_TRACKS_PER_JOB)

    args = offsets.map { |offset| [playlist.id, playlist.class.to_s, track_data.id, offset] }
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
end
