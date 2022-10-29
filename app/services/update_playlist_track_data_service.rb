# frozen_string_literal: true

require 'has_spotify_client'

class UpdatePlaylistTrackDataService < ApplicationService
  include HasSpotifyClient

  attr_reader :playlist, :track_data

  def initialize(playlist)
    @playlist = playlist
    @track_data = playlist.track_data.create!
  end

  def call
    spotify_playlist = playlist.to_rspotify_playlist
    playlist.sync_with_spotify!(spotify_playlist)

    response = spotify_client.get_tracks(spotify_playlist)
    process_response(response)

    while response.next_url.present?
      offset = response.calculate_next_offset
      response = spotify_client.get_tracks(spotify_playlist, offset:)
      process_response(response)
    end
    track_data.completed!
  end

  private

  def process_response(response)
    tracks = response.import_tracks_and_artists!

    track_data.tracks << tracks
    log_service_progress(response)
  end

  def log_service_progress(response)
    Rails.logger.info(
      {
        playlist_name: playlist.name,
        user_name: playlist.user.spotify_id,
        offset: response.offset
      }
    )
  end
end
