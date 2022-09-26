# frozen_string_literal: true

require 'rails_helper'
require 'spotify_client'

describe SpotifyClient, :vcr do
  describe '.get_playlist_by_id' do
    let(:playlist_id) { '3IlD894HSWDF8YlkCP25Sq' }

    it 'returns the correct playlist' do
      expect(described_class.get_playlist_by_id(playlist_id).id).to eq playlist_id
    end
  end

  describe '.get_artists_by_ids' do
    let(:artist_id) { '1iNbNgr25BaS5e9a8xUZ9J' }
    let(:artist_ids) { %w[1iNbNgr25BaS5e9a8xUZ9J 3ggwAqZD3lyT2sbovlmfQY] }

    context 'when it is called with a single artist_id' do
      it 'returns the correct artist' do
        expect(described_class.get_artists_by_ids(artist_id).id).to eq artist_id
      end
    end

    context 'when it is called with multiple artist_ids' do
      it 'returns an array with the correct artists in it' do
        expect(described_class.get_artists_by_ids(artist_ids).map(&:id)).to match_array artist_ids
      end
    end
  end
end
