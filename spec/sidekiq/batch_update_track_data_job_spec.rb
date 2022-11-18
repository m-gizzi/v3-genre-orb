# frozen_string_literal: true

require 'rails_helper'

describe BatchUpdateTrackDataJob do
  let(:playlist_ids) { Array.new(4) { generate_spotify_id } }

  before do
    build_list(:playlist, 4, user: build(:user)).each_with_index do |playlist, i|
      playlist.spotify_id = playlist_ids[i]
      playlist.save!
    end
    create(:liked_songs_playlist)
  end

  describe '#perform' do
    it 'enqueues an UpdatePlaylistTrackDataJob for each eligible Playlist and LikedSongsPlaylist' do
      expect do
        described_class.perform_async
        described_class.drain
      end.to change(UpdatePlaylistTrackDataBatchQueuingJob.jobs, :size).by(5)
    end
  end
end
