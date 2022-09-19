# frozen_string_literal: true

class UpdatePlaylistTrackDataService < ApplicationService
  attr_reader :playlist, :offset

  def initialize(playlist, offset: 0)
    @playlist = playlist
    @offset = offset
  end

  def call
    spotify_playlist = playlist.to_rspotify_playlist
    response = spotify_playlist.tracks(offset:, raw_response: true)
    process_response(response)
    # somehow, I'll make another job queue when there's a next_url in the response
  end

  private

  def process_response(response)
    tracks = response['items'].map do |track_hash|
      track_attributes = track_hash['track']

      track = find_or_create_object_from_attributes!(Track, track_attributes)

      track.artists = track_attributes['artists'].map do |artist_attributes|
        find_or_create_object_from_attributes!(Artist, artist_attributes)
      end

      track
    end
    maybe_create_track_data
    playlist.current_track_data.tracks |= tracks
  end

  def find_or_create_object_from_attributes!(klass, attributes)
    klass.create_with(name: attributes['name']).find_or_create_by!(spotify_id: attributes['id'])
  end

  # This is a placeholder while I figure out how to intelligently create new track_data as well as the first
  # track_data for playlists that have never been scraped
  def maybe_create_track_data
    playlist.track_data.create! if playlist.track_data.empty?
  end
end
