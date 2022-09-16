# frozen_string_literal: true

class SpotifyClient
  def self.get_playlist(playlist_id)
    # rubocop:disable Rails/DynamicFindBy
    RSpotify::Playlist.find_by_id(playlist_id)
    # rubocop:enable Rails/DynamicFindBy
  end
end
