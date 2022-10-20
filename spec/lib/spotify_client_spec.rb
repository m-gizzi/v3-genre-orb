# frozen_string_literal: true

require 'rails_helper'
require 'spotify_client'

describe SpotifyClient, :vcr do
  subject(:client) { described_class.new }

  describe '#get_playlist_by_id' do
    let(:playlist_id) { '3IlD894HSWDF8YlkCP25Sq' }

    it 'returns the correct playlist' do
      expect(client.get_playlist_by_id(playlist_id).id).to eq playlist_id
    end
  end

  describe '#get_artists_by_ids' do
    let(:artist_ids) { %w[1iNbNgr25BaS5e9a8xUZ9J 3ggwAqZD3lyT2sbovlmfQY] }

    it 'returns an array with the correct artists in it' do
      expect(client.get_artists_by_ids(artist_ids).map(&:id)).to match_array artist_ids
    end

    context 'when it is called with too many artist_ids' do
      let(:too_many_artist_ids) { Array.new(51) { generate_spotify_id } }

      it 'raises an error' do
        expect { client.get_artists_by_ids(too_many_artist_ids) }.to raise_error(ArgumentError)
      end
    end

  describe '#get_related_artists' do
    let(:artist) { create(:artist) }
    let(:rspotify_artist) { artist.to_rspotify_artist }

    it 'returns the artist\'s related artists' do
      expect(client.get_related_artists(rspotify_artist)).to all(be_a(RSpotify::Artist))
    end
  end
end
