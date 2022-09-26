# frozen_string_literal: true

require 'rails_helper'
require 'spotify_client'

describe SpotifyClient do
  describe '.get_rspotify_playlist_by_id' do
    let(:playlist_id) { '3IlD894HSWDF8YlkCP25Sq' }

    it 'returns an RSpotify::Playlist', :vcr do
      expect(described_class.get_rspotify_playlist_by_id(playlist_id)).to be_a(RSpotify::Playlist)
    end

    it 'returns the correct playlist', :vcr do
      expect(described_class.get_rspotify_playlist_by_id(playlist_id).id).to eq playlist_id
    end
  end
end
