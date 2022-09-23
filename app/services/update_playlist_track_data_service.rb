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
    playlist.track_data.create!

    spotify_playlist = playlist.to_rspotify_playlist
    response = Response.new(spotify_playlist.tracks(raw_response: true))
    process_response(response)

    while response.next_url.present?
      offset = response.calculate_next_offset
      Rails.logger.info(offset)
      response = Response.new(spotify_playlist.tracks(offset:, raw_response: true))
      process_response(response)
    end
  end

  private

  def process_response(response)
    tracks = response.items.map do |track_hash|
      track_attributes = track_hash['track']
      track = find_or_create_object_from_attributes!(Track, track_attributes)

      track.artists = track_attributes['artists'].map do |artist_attributes|
        find_or_create_object_from_attributes!(Artist, artist_attributes)
      end

      track
    end

    tracks_to_add_ids = determine_tracks_to_add(tracks)
    playlist.current_track_data.tracks << Track.where(id: tracks_to_add_ids)
  end

  def find_or_create_object_from_attributes!(klass, attributes)
    klass.create_with(name: attributes['name']).find_or_create_by!(spotify_id: attributes['id'])
  end

  def determine_tracks_to_add(incoming_tracks)
    incoming_tracks.pluck(:id) - playlist.current_track_data.tracks.ids
  end
end
