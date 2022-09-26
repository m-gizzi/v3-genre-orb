# frozen_string_literal: true

class SpotifyClient
  def self.get_playlist_by_id(playlist_id)
    # rubocop:disable Rails/DynamicFindBy
    RSpotify::Playlist.find_by_id(playlist_id)
    # rubocop:enable Rails/DynamicFindBy
  end

  def self.get_artists_by_ids(artist_ids)
    RSpotify::Artist.find(artist_ids)
  end
end
