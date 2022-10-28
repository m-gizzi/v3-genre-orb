# frozen_string_literal: true

require 'responses/response'

class SpotifyClient
  def get_playlist_by_id(playlist_id)
    # rubocop:disable Rails/DynamicFindBy
    RSpotify::Playlist.find_by_id(playlist_id)
    # rubocop:enable Rails/DynamicFindBy
  end

  MAXIMUM_ARTIST_LOOKUPS_PER_CALL = 50 # RSpotify::Artist.find has a limit of 50 ids
  def get_artists_by_ids(artist_ids)
    if artist_ids.count > MAXIMUM_ARTIST_LOOKUPS_PER_CALL
      raise ArgumentError, "#{__method__} cannot accept more than #{MAXIMUM_ARTIST_LOOKUPS_PER_CALL} ids as arguments"
    end

    handle_retryable_error(RestClient::TooManyRequests) do
      RSpotify::Artist.find(artist_ids)
    end
  end

  def get_related_artists(rspotify_artist)
    handle_retryable_error(RestClient::TooManyRequests) do
      rspotify_artist.related_artists
    end
  end

  def get_tracks(rspotify_playlist, offset: 0)
    raw_response = rspotify_playlist.tracks(raw_response: true, offset:)
    Responses::GetTracks.new(raw_response)
  end

  def get_liked_tracks(rspotify_user, offset: 0)
    # RSpotify::User.saved_tracks has a maximum limit of 50 tracks returned
    raw_response = rspotify_user.saved_tracks(raw_response: true, limit: 50, offset:)
    Responses::GetTracks.new(raw_response)
  end

  private

  def handle_retryable_error(rescued_exception_classes)
    yield
  rescue *rescued_exception_classes => e
    Bugsnag.notify(e)
    sleep(seconds_to_retry_after(e))
    retry
  end

  def seconds_to_retry_after(error)
    # Spotify returns a header that tells you the number of seconds to wait before trying again
    error.http_headers[:retry_after].to_i
  end
end
