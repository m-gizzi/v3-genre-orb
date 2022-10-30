# frozen_string_literal: true

require 'has_spotify_client'

class UpdatePlaylistTrackDataService < ApplicationService
  include HasSpotifyClient

  attr_reader :playlist, :track_data, :offset, :self_queuing, :response

  def initialize(playlist, track_data: nil, offset: 0, self_queuing: nil)
    @playlist = playlist
    @track_data = track_data || playlist.track_data.create!
    @offset = offset
    @self_queuing = self_queuing
  end

  def call
    @response = make_api_call
    playlist.sync_with_spotify!(object_to_be_synced_with) # Check to see if it's worth only doing this sometimes

    process_response(response)

    if response.next_url.present?
      handle_self_queuing
    else
      track_data.completed!
    end
  end

  private

  def rspotify_object
    playlist.to_rspotify_playlist
  end

  def object_to_be_synced_with
    rspotify_object
  end

  def make_api_call
    spotify_client.get_tracks(rspotify_object, offset:)
  end

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

  def handle_self_queuing
    offset = response.calculate_next_offset
    case self_queuing
    when 'asynchronous'
      UpdatePlaylistTrackDataJob.perform_async(playlist.id, playlist.class.to_s, self_queuing, track_data.id, offset)
    when 'synchronous'
      playlist.update_track_data!(track_data:, offset:, self_queuing:)
    end
  end
end
