# frozen_string_literal: true

require 'rails_helper'

describe UpdatePlaylistTrackDataBatchQueuingJob do
  describe '#perform', :vcr do
    context 'when a Playlist is passed as an argument' do
      let(:playlist) { create(:playlist, :many_tracks) }

      it 'queues UpdatePlaylistTrackDataJob for the playlist' do
        expect do
          described_class.perform_async(playlist.id, playlist.class.to_s)
          described_class.drain
        end.to change(UpdatePlaylistTrackDataJob.jobs, :size)
      end
    end

    context 'when a LikedSongsPlaylist is passed as an argument' do
      let(:playlist) { create(:liked_songs_playlist) }

      it 'queues UpdatePlaylistTrackDataJob for the playlist' do
        expect do
          described_class.perform_async(playlist.id, playlist.class.to_s)
          described_class.drain
        end.to change(UpdatePlaylistTrackDataJob.jobs, :size)
      end
    end
  end
end
