# frozen_string_literal: true

require 'rails_helper'
require 'spotify_client'

describe LikedSongsPlaylist, type: :model do
  subject(:playlist) { create(:liked_songs_playlist) }

  let(:user) { playlist.user }

  describe '#sync_with_spotify!' do
    it 'updates the song_count of the playlist', :vcr do
      response = SpotifyClient.new.get_liked_tracks(user.to_rspotify_user)
      expect { playlist.sync_with_spotify!(response) }.to(change(playlist, :song_count))
    end
  end
end
