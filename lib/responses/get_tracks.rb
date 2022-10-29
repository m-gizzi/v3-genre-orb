# frozen_string_literal: true

module Responses
  class GetTracks
    attr_reader :items, :limit, :offset, :next_url, :total

    def initialize(response)
      @items = response['items']
      @limit = response['limit']
      @offset = response['offset']
      @next_url = response['next']
      @total = response['total']
    end

    def calculate_next_offset
      limit + offset
    end

    def import_tracks_and_artists!
      items.map do |track_hash|
        track_attributes = track_hash['track']
        artist_attributes = track_attributes['artists']

        track = find_or_create_track_from_attributes!(track_attributes)
        track.artists = find_or_create_artists_from_attributes!(artist_attributes)

        track
      end
    end

    private

    def find_or_create_track_from_attributes!(track_attributes)
      Track.create_with(name: track_attributes['name']).find_or_create_by!(spotify_id: track_attributes['id'])
    end

    def find_or_create_artists_from_attributes!(artist_attributes)
      artist_attributes.map do |attributes|
        Artist.create_with(name: attributes['name']).find_or_create_by!(spotify_id: attributes['id'])
      end
    end
  end
end
