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
    track_data = playlist.track_data.create!
    # Maybe make response a class
    response['items'].each do |track_hash|
      track = Track.create_with(name: track_hash['track']['name']).find_or_create_by!(spotify_id: track_hash['track']['id'])
      artists = track_hash['track']['artists'].map do |artist_hash|
        Artist.create_with(name: artist_hash['name']).find_or_create_by!(spotify_id: artist_hash['id'])
      end
      track.artists |= artists
      track_data.tracks << track
    end
    # somehow, I'll make another job queue when there's a next_url in the response
  end
end
