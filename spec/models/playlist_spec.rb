# frozen_string_literal: true

require 'rails_helper'

describe Playlist, type: :model do
  subject(:playlist) { create(:playlist) }

  describe '#to_rspotify_playlist', :vcr do
    it 'returns an RSpotify::Playlist' do
      expect(playlist.to_rspotify_playlist).to be_a(RSpotify::Playlist)
    end

    it 'finds the correct playlist' do
      expect(playlist.to_rspotify_playlist.id).to eq playlist.spotify_id
    end

    it 'updates the name and song_count of the playlist' do
      expect { playlist.to_rspotify_playlist }.to change { playlist.reload.name }.and(change { playlist.reload.song_count })
    end

    context 'when the name and song_count are the same as currently saved in the database' do
      subject(:playlist) { create(:playlist, song_count: 5, name: 'Genre Orb Test Playlist') }

      it 'does not save any changes to the Playlist' do
        expect { playlist.to_rspotify_playlist }.to avoid_changing { playlist.reload.name }.and(avoid_changing { playlist.reload.song_count })
      end
    end
  end
end
