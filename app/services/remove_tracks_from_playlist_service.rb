# frozen_string_literal: true

require 'has_spotify_client'

class RemoveTracksFromPlaylistService < ApplicationService
  include HasSpotifyClient

  attr_reader :playlist, :track_uris

  def initialize(playlist, track_uris)
    @playlist = playlist
    @track_uris = track_uris
  end

  def call
    playlist.user.authorize
    rspotify_playlist = playlist.to_rspotify_playlist
    track_uris.in_batches(batch_size: SpotifyClient::MAXIMUM_TRACKS_REMOVED_PER_CALL) do |uris|
      spotify_client.remove_tracks_from_playlist!(rspotify_playlist, uris)
    end
  end
end
