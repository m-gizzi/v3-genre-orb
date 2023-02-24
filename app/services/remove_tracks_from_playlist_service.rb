# frozen_string_literal: true

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
    spotify_client.remove_tracks_from_playlist!(rspotify_playlist, track_uris)
  end
end
