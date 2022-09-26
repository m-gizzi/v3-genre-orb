# frozen_string_literal: true

class SpotifyClient
  def self.get_playlist_by_id(playlist_id)
    # rubocop:disable Rails/DynamicFindBy
    RSpotify::Playlist.find_by_id(playlist_id)
    # rubocop:enable Rails/DynamicFindBy
  end

  def self.get_artists_by_ids(artist_ids)
    maximum_artist_ids_per_call = 50
    if artist_ids.count > maximum_artist_ids_per_call
      raise ArgumentError, "#{__method__} cannot accept more than #{maximum_artist_ids_per_call} ids as arguments"
    end

    RSpotify::Artist.find(artist_ids)
  end
end
