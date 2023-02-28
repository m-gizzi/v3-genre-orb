# frozen_string_literal: true

require 'rails_helper'

describe RemoveTracksFromPlaylistJob, type: :job do
  describe '#perform' do
    let(:playlist) { create(:playlist, user:) }
    let(:user) { create(:user, :with_spotify_tokens, spotify_id: '31upmxyqdkt5utuji6r5wsrkgn4e') } # fixture user
    let(:tracks) { create_list(:track, 2) }
    let!(:target_stub) do
      # Url includes fixture playlist_id
      stub_request(:delete, "https://api.spotify.com/v1/users/#{user.spotify_id}/playlists/3nwz2mVTVbWSGMSFMzN7pu/tracks")
        .to_return(status: 201, body: { snapshot_id: generate_spotify_id }.to_json)
    end

    before do
      stub_request(:get, "https://api.spotify.com/v1/playlists/#{playlist.spotify_id}")
        .to_return(status: 200, body: File.read('spec/fixtures/successful_get_playlist.json'))
    end

    it 'makes a call to Spotify to remove the tracks from the playlist' do
      described_class.perform_async(playlist.id, tracks.pluck(:id))
      expect(target_stub).to have_been_requested
    end
  end
end
