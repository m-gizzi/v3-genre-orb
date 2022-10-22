# frozen_string_literal: true

class UpdatePlaylistTrackDataService < ApplicationService
  class Response
    attr_reader :items, :limit, :offset, :next_url

    def initialize(response)
      @items = response['items']
      @limit = response['limit']
      @offset = response['offset']
      @next_url = response['next']
    end

    def calculate_next_offset
      limit + offset
    end
  end

  attr_reader :playlist

  def initialize(playlist)
    @playlist = playlist
  end

  def call
    spotify_playlist = playlist.to_rspotify_playlist
    playlist.sync_with_spotify!(spotify_playlist)

    response = Response.new(spotify_playlist.tracks(raw_response: true))
    process_response(response)

    while response.next_url.present?
      offset = response.calculate_next_offset
      response = Response.new(spotify_playlist.tracks(offset:, raw_response: true))
      process_response(response)
    end
    track_data.completed!
  end

  private

  def track_data
    @track_data ||= playlist.track_data.create!
  end

  def process_response(response)
    tracks = response.items.map do |track_hash|
      track_attributes = track_hash['track']
      artist_attributes = track_attributes['artists']

      track = find_or_create_track_from_attributes!(track_attributes)
      track.artists = find_or_create_artists_from_attributes!(artist_attributes)

      track
    end

    track_data.tracks << tracks
    log_service_progress(response)
  end

  def find_or_create_track_from_attributes!(track_attributes)
    Track.create_with(name: track_attributes['name']).find_or_create_by!(spotify_id: track_attributes['id'])
  end

  def find_or_create_artists_from_attributes!(artist_attributes)
    artist_attributes.map do |attributes|
      Artist.create_with(name: attributes['name']).find_or_create_by!(spotify_id: attributes['id'])
    end
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
