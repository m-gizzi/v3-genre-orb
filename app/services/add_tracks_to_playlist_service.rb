# frozen_string_literal: true

require 'has_spotify_client'

class AddTracksToPlaylistService < ApplicationService
  include HasSpotifyClient

  attr_reader :playlist, :tracks

  def initialize(playlist, tracks)
    @playlist = playlist
    @tracks = tracks
  end

  def call
    playlist.user.authorize

    rspotify_playlist = playlist.to_rspotify_playlist
    track_uris = tracks.pluck(:uri)

    track_uris.in_groups_of(SpotifyClient::MAXIMUM_TRACKS_ADDED_PER_CALL, false) do |uris|
      spotify_client.add_tracks_to_playlist!(rspotify_playlist, uris)
    end
  end
end
