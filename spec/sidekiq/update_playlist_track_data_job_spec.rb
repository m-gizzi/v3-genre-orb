# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdatePlaylistTrackDataJob, type: :job do
  let(:playlist) { create(:playlist) }

  describe '#perform', :vcr do
    around do |test|
      Sidekiq::Testing.inline! do
        test.run
      end
    end

    it 'creates a new TrackData to log the scraped data' do
      expect { described_class.perform_async(playlist.id) }.to change(TrackData, :count).by(1)
    end

    it 'associates all the Tracks from the response to the new TrackData' do
      described_class.perform_async(playlist.id)
      expect(playlist.reload.current_track_data.tracks.count).to eq playlist.song_count
    end
  end
end
