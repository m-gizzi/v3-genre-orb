# frozen_string_literal: true

require 'responses/response'

class SpotifyClient
  attr_accessor :exception

  SPOTIFY_SIDEKIQ_QUEUES = [
    Sidekiq::Queue['spotify_api_calls'],
    Sidekiq::Queue['low_rate_spotify_api_calls']
  ].freeze

  def get_playlist_by_id(playlist_id)
    handle_too_many_requests_error do
      # rubocop:disable Rails/DynamicFindBy
      RSpotify::Playlist.find_by_id(playlist_id)
      # rubocop:enable Rails/DynamicFindBy
    end
  end

  MAXIMUM_ARTIST_LOOKUPS_PER_CALL = 50 # RSpotify::Artist.find has a limit of 50 ids
  def get_artists_by_ids(artist_ids)
    if artist_ids.count > MAXIMUM_ARTIST_LOOKUPS_PER_CALL
      raise ArgumentError, "#{__method__} cannot accept more than #{MAXIMUM_ARTIST_LOOKUPS_PER_CALL} ids as arguments"
    end

    handle_too_many_requests_error do
      RSpotify::Artist.find(artist_ids)
    end
  end

  def get_related_artists(rspotify_artist)
    handle_too_many_requests_error do
      rspotify_artist.related_artists
    end
  end

  def get_tracks(rspotify_playlist, offset: 0)
    handle_too_many_requests_error do
      raw_response = rspotify_playlist.tracks(raw_response: true, offset:)
      Responses::GetTracks.new(raw_response)
    end
  end

  def get_liked_tracks(rspotify_user, offset: 0)
    handle_too_many_requests_error do
      # RSpotify::User.saved_tracks has a maximum limit of 50 tracks returned
      raw_response = rspotify_user.saved_tracks(raw_response: true, limit: 50, offset:)
      Responses::GetTracks.new(raw_response)
    end
  end

  MAXIMUM_TRACKS_ADDED_PER_CALL = 100 # RSpotify::Playlist#add_tracks! has a limit of 100 tracks
  def add_tracks_to_playlist!(rspotify_playlist, track_uris)
    if track_uris.count > MAXIMUM_TRACKS_ADDED_PER_CALL
      raise ArgumentError, "#{__method__} cannot accept more than #{MAXIMUM_TRACKS_ADDED_PER_CALL} uris as arguments"
    end

    handle_too_many_requests_error do
      rspotify_playlist.add_tracks!(track_uris, position: 0)
    end
  end

  MAXIMUM_TRACKS_REMOVED_PER_CALL = 100 # RSpotify::Playlist#remove_tracks! has a limit of 100 tracks
  def remove_tracks_from_playlist!(rspotify_playlist, track_uris)
    if track_uris.count > MAXIMUM_TRACKS_REMOVED_PER_CALL
      raise ArgumentError, "#{__method__} cannot accept more than #{MAXIMUM_TRACKS_REMOVED_PER_CALL} uris as arguments"
    end

    handle_too_many_requests_error do
      rspotify_playlist.remove_tracks!(track_uris)
    end
  end

  private

  def handle_too_many_requests_error
    yield
  rescue RestClient::TooManyRequests => e
    self.exception = e
    pause_queues
    log_error
    sleep(seconds_to_retry_after)
    retry
  end

  def seconds_to_retry_after
    error_retry_after_header.to_i + 1
  end

  def error_retry_after_header
    # Spotify returns a header that tells you the number of seconds to wait before trying again
    exception.http_headers[:retry_after]
  end

  def pause_queues
    SPOTIFY_SIDEKIQ_QUEUES.each { |queue| queue.pause_for_ms(seconds_to_retry_after * 1000) }
  end

  def log_error
    Bugsnag.notify(exception) { |event| event.add_metadata(:diagnostics, { headers: exception.http_headers }) }
  end
end
