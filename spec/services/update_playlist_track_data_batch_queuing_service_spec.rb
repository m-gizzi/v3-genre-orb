# frozen_string_literal: true

require 'rails_helper'

describe UpdatePlaylistTrackDataBatchQueuingService do
  subject(:service) { described_class.new(playlist) }

  describe '#call' do
    context 'when a Playlist is passed as to the service when initializing it' do
      let(:playlist) { create(:playlist, song_count:) }
      let(:song_count) { 116 }
      let(:target_number_of_jobs) { (song_count.to_f / 100).ceil }

      before do
        stub_request(:get, "https://api.spotify.com/v1/playlists/#{playlist.spotify_id}")
          .to_return(status: 200, body: File.read('spec/fixtures/successful_get_playlist.json'))

        allow(playlist).to receive(:song_count).and_return(song_count)
      end

      it 'enqueues an UpdatePlaylistTrackDataJob for every 100 tracks the playlist has' do
        expect { service.call }.to change(UpdatePlaylistTrackDataJob.jobs, :size).by(target_number_of_jobs)
      end
    end

    context 'when a LikedSongsPlaylist is passed to the service when initializing it' do
      let(:playlist) { create(:liked_songs_playlist, song_count:) }
      let(:song_count) { 66 }
      let(:target_number_of_jobs) { (song_count.to_f / 50).ceil }

      before do
        stub_request(:get, 'https://api.spotify.com/v1/me/tracks?limit=50&offset=0')
          .to_return(status: 200, body: File.read('spec/fixtures/successful_get_liked_tracks.json'))

        allow(playlist).to receive(:song_count).and_return(song_count)
      end

      it 'enqueues an UpdatePlaylistTrackDataJob for every 50 tracks the playlist has' do
        expect { service.call }.to change(UpdatePlaylistTrackDataJob.jobs, :size).by(target_number_of_jobs)
      end
    end
  end
end
