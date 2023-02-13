# frozen_string_literal: true

require 'rails_helper'

describe UpdatePlaylistTrackDataBatchQueuingJob do
  describe '#perform' do
    context 'when a Playlist is passed as an argument' do
      let(:playlist) { create(:playlist) }

      before do
        stub_request(:get, "https://api.spotify.com/v1/playlists/#{playlist.spotify_id}")
          .to_return(status: 200, body: File.read('spec/fixtures/successful_get_playlist.json'))
      end

      it 'queues UpdatePlaylistTrackDataJob for the playlist' do
        expect do
          described_class.perform_async(playlist.id, playlist.class.to_s)
          described_class.drain
        end.to change(UpdatePlaylistTrackDataJob.jobs, :size)
      end
    end

    context 'when a LikedSongsPlaylist is passed as an argument' do
      let(:playlist) { create(:liked_songs_playlist) }

      before do
        stub_request(:get, 'https://api.spotify.com/v1/me/tracks?limit=50&offset=0')
          .to_return(status: 200, body: File.read('spec/fixtures/successful_get_liked_tracks.json'))
      end

      it 'queues UpdatePlaylistTrackDataJob for the playlist' do
        expect do
          described_class.perform_async(playlist.id, playlist.class.to_s)
          described_class.drain
        end.to change(UpdatePlaylistTrackDataJob.jobs, :size)
      end
    end
  end
end
