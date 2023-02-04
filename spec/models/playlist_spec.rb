# frozen_string_literal: true

require 'rails_helper'

describe Playlist, type: :model do
  subject(:playlist) { create(:playlist) }

  before do
    stub_request(:get, "https://api.spotify.com/v1/playlists/#{playlist.spotify_id}")
      .to_return(status: 200, body: File.read('spec/fixtures/successful_get_playlist.json'))
  end

  describe '#to_rspotify_playlist' do
    it 'returns an RSpotify::Playlist' do
      expect(playlist.to_rspotify_playlist).to be_a(RSpotify::Playlist)
    end
  end

  describe '#sync_with_spotify!' do
    it 'updates the name and song_count of the playlist' do
      expect { playlist.sync_with_spotify!(playlist.to_rspotify_playlist) }.to change { playlist.reload.name }
        .and(change { playlist.reload.song_count })
    end

    context 'when the name and song_count are the same as currently saved in the database' do
      subject(:playlist) { create(:playlist, song_count: 20, name: 'Test Playlist') }

      it 'does not save any changes to the Playlist' do
        expect { playlist.sync_with_spotify!(playlist.to_rspotify_playlist) }.to avoid_changing { playlist.reload.name }
          .and(avoid_changing { playlist.reload.song_count })
      end
    end
  end
end
