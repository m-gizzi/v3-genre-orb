# frozen_string_literal: true

require 'rails_helper'

describe AddTracksToPlaylistService do
  describe '#call' do
    let(:playlist) { create(:playlist, user:) }
    let(:user) { create(:user, :with_spotify_tokens, spotify_id: '31upmxyqdkt5utuji6r5wsrkgn4e') } # fixture user
    let(:tracks) { create_list(:track, 2) }
    let!(:target_stub) do
      stub_request(:post, 'https://api.spotify.com/v1/playlists/3nwz2mVTVbWSGMSFMzN7pu/tracks') # fixture playlist url
        .to_return(status: 201, body: { snapshot_id: generate_spotify_id }.to_json)
    end

    before do
      stub_request(:get, "https://api.spotify.com/v1/playlists/#{playlist.spotify_id}")
        .to_return(status: 200, body: File.read('spec/fixtures/successful_get_playlist.json'))
    end

    it 'makes a call to Spotify to add the tracks to the playlist' do
      described_class.call(playlist, tracks)
      expect(target_stub).to have_been_requested
    end

    context 'when passes a lot of track_uris as arguments' do
      let(:tracks) { create_list(:track, 101) }

      it 'makes multiple calls to Spotify' do
        described_class.call(playlist, tracks)
        expect(target_stub).to have_been_requested.times(2)
      end
    end
  end
end
