# frozen_string_literal: true

class SpotifyClient
  def self.get_playlist_by_id(playlist_id)
    # rubocop:disable Rails/DynamicFindBy
    RSpotify::Playlist.find_by_id(playlist_id)
    # rubocop:enable Rails/DynamicFindBy
  end

  MAXIMUM_ARTIST_LOOKUPS_PER_CALL = 50 # RSpotify::Artist.find has a limit of 50 ids

  def self.get_artists_by_ids(artist_ids)
    if artist_ids.count > MAXIMUM_ARTIST_LOOKUPS_PER_CALL
      raise ArgumentError, "#{__method__} cannot accept more than #{MAXIMUM_ARTIST_LOOKUPS_PER_CALL} ids as arguments"
    end

    RSpotify::Artist.find(artist_ids)
  end
end
