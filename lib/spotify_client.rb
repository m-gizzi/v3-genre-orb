# frozen_string_literal: true

class SpotifyClient
  def get_playlist_by_id(playlist_id)
    # rubocop:disable Rails/DynamicFindBy
    RSpotify::Playlist.find_by_id(playlist_id)
    # rubocop:enable Rails/DynamicFindBy
  end

  def get_artists_by_ids(artist_ids)
    maximum_artist_lookups_per_call = 50 # RSpotify::Artist.find has a limit of 50 ids

    if artist_ids.count > maximum_artist_lookups_per_call
      raise ArgumentError, "#{__method__} cannot accept more than #{maximum_artist_lookups_per_call} ids as arguments"
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

  private

  def handle_retryable_error(rescued_exception_classes)
    yield
  rescue *rescued_exception_classes => e
    Bugsnag.notify(e)
    sleep(seconds_to_retry_after(e))
    retry
  end

  def seconds_to_retry_after(error)
    if defined? error.http_headers[:retry_after]
      # Spotify returns a header that tells you the number of seconds to wait before trying again
      error.http_headers[:retry_after].to_i
    else
      1 # Default time to sleep
    end
  end
end
