# frozen_string_literal: true

require 'has_spotify_client'

class UpdatePlaylistTrackDataService < ApplicationService
  include HasSpotifyClient

  attr_reader :playlist, :track_data, :offset, :self_queuing

  def initialize(playlist, track_data: nil, offset: 0, self_queuing: nil)
    @playlist = playlist
    @track_data = track_data || playlist.track_data.create!
    @offset = offset
    @self_queuing = self_queuing
  end

  def call
    spotify_playlist = playlist.to_rspotify_playlist
    playlist.sync_with_spotify!(spotify_playlist) # Check to see if it's worth only doing this sometimes

    response = spotify_client.get_tracks(spotify_playlist, offset:)
    process_response(response)

    if response.next_url.present?
      offset = response.calculate_next_offset
      case self_queuing
      when 'asynchronous'
        UpdatePlaylistTrackDataJob.perform_async(playlist.id, self_queuing, track_data.id, offset)
      when 'synchronous'
        playlist.update_track_data!(track_data:, offset:, self_queuing:)
      end
    else
      track_data.completed!
    end
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
