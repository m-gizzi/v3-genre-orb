# frozen_string_literal: true

require 'rails_helper'

describe UpdatePlaylistTrackDataBatchQueuingService do
  subject(:service) { described_class.new(playlist) }

  describe '#call', :vcr do
    context 'when a Playlist is passed as to the service when initializing it' do
      let(:playlist) { create(:playlist, :many_tracks, song_count:) }
      let(:song_count) { 116 }
      let(:target_number_of_jobs) { (song_count.to_f / 100).ceil }

      it 'enqueues an UpdatePlaylistTrackDataJob for every 100 tracks the playlist has' do
        expect { service.call }.to change(UpdatePlaylistTrackDataJob.jobs, :size).by(target_number_of_jobs)
      end
    end

    context 'when a LikedSongsPlaylist is passed to the service when initializing it' do
      let(:playlist) { create(:liked_songs_playlist, song_count:) }
      let(:song_count) { 16 }
      let(:target_number_of_jobs) { (song_count.to_f / 50).ceil }

      it 'enqueues an UpdatePlaylistTrackDataJob for every 50 tracks the playlist has' do
        expect { service.call }.to change(UpdatePlaylistTrackDataJob.jobs, :size).by(target_number_of_jobs)
      end
    end
  end
end
