# frozen_string_literal: true

require 'rails_helper'
require 'spotify_client'

describe SpotifyClient do
  describe '.get_playlist' do
    let(:playlist_id) { '3IlD894HSWDF8YlkCP25Sq' }

    it 'returns an RSpotify::Playlist', :vcr do
      expect(described_class.get_playlist(playlist_id)).to be_a(RSpotify::Playlist)
    end

    it 'returns the correct playlist', :vcr do
      expect(described_class.get_playlist(playlist_id).id).to eq playlist_id
    end
  end
end
