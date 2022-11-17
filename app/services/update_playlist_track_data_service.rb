# frozen_string_literal: true

require 'has_spotify_client'

class UpdatePlaylistTrackDataService < ApplicationService
  include HasSpotifyClient

  attr_reader :playlist, :track_data, :offset

  def initialize(playlist, track_data, offset: 0)
    @playlist = playlist
    @track_data = track_data
    @offset = offset
  end

  def call
    response = handle_fetching_tracks
    create_records_from_response(response)

    track_data.completed! if track_data.tracks.reload.count == response.total
  end

  private

  def handle_fetching_tracks
    case playlist.class.to_s
    when 'Playlist'
      handle_fetching_playlist_tracks
    when 'LikedSongsPlaylist'
      handle_fetching_liked_songs_playlist
    end
  end

  def handle_fetching_playlist_tracks
    rspotify_playlist = playlist.to_rspotify_playlist
    playlist.sync_with_spotify!(rspotify_playlist)

    spotify_client.get_tracks(rspotify_playlist, offset:)
  end

  def handle_fetching_liked_songs_playlist
    rspotify_user = playlist.user.to_rspotify_user
    response = spotify_client.get_liked_tracks(rspotify_user, offset:)

    playlist.sync_with_spotify!(response)

    response
  end

  def create_records_from_response(response)
    tracks = response.items.map do |track_hash|
      track_attributes = track_hash['track']
      artist_attributes = track_attributes['artists']

      track = find_or_create_track_from_attributes!(track_attributes)
      track.artists = find_or_create_artists_from_attributes!(artist_attributes)

      track
    end

    track_data.tracks << tracks
  end

  def find_or_create_track_from_attributes!(track_attributes)
    Track.create_with(name: track_attributes['name']).find_or_create_by!(spotify_id: track_attributes['id'])
  end

  def find_or_create_artists_from_attributes!(artist_attributes)
    artist_attributes.map do |attributes|
      Artist.create_with(name: attributes['name']).find_or_create_by!(spotify_id: attributes['id'])
    end
  end
end
