# frozen_string_literal: true

require 'rails_helper'

describe BatchUpdateTrackDataJob do
  let(:playlist_ids) { Array.new(4) { generate_spotify_id } }
  let(:playlist) { create(:playlist) }

  before do
    build_list(:playlist, 4, user: build(:user)).each_with_index do |playlist, i|
      playlist.spotify_id = playlist_ids[i]
      playlist.save!
    end
  end

  describe '#perform' do
    it 'enqueues an UpdatePlaylistTrackDataJob for each eligible Playlist' do
      expect do
        described_class.perform_async
        described_class.drain
      end.to change(UpdatePlaylistTrackDataJob.jobs, :size).by(4)
    end
  end
end
