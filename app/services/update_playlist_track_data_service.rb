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
    response = handle_fetching_tracks
    process_response(response)

    if response.next_url.present?
      handle_self_queuing(response)
    else
      track_data.completed!
    end
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

  def process_response(response)
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

  def handle_self_queuing(response)
    offset = response.calculate_next_offset
    case self_queuing
    when 'asynchronous'
      UpdatePlaylistTrackDataJob.perform_async(playlist.id, playlist.class.to_s, self_queuing, track_data.id, offset)
    when 'synchronous'
      playlist.update_track_data!(track_data:, offset:, self_queuing:)
    end
  end
end
