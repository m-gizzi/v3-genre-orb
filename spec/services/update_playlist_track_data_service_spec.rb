# frozen_string_literal: true

require 'rails_helper'

describe UpdatePlaylistTrackDataService do
  subject(:service) { described_class.new(playlist) }

  let(:playlist) { create(:playlist) }

  describe '#call', :vcr do
    it 'creates a new TrackData to log the scraped data and marks it as complete' do
      expect { service.call }.to change { TrackData.completed.count }.by(1)
    end

    it 'creates new Tracks from the response' do
      playlist.sync_with_spotify!(playlist.to_rspotify_playlist)
      expect { service.call }.to change(Track, :count).by(playlist.song_count)
    end

    context 'when a track is returned that already exists in the database' do
      it 'does not create a duplicate' do
        service.call
        expect { service.call }.not_to change(Track, :count)
      end
    end

    it 'creates new Artists from the response' do
      expect { service.call }.to change(Artist, :count)
    end

    context 'when a artist is returned that already exists in the database' do
      it 'does not create a duplicate' do
        service.call
        expect { service.call }.not_to change(Artist, :count)
      end
    end

    it 'associates all the Artists from the response with their Tracks' do
      service.call
      expect(Track.all.map(&:artists)).to all(be_present)
    end

    it 'associates all the Tracks from the response to the new TrackData' do
      service.call
      expect(playlist.current_track_data.tracks.count).to eq playlist.song_count
    end

    context "when multiple calls must be made to fetch all the playlist's tracks" do
      let(:playlist) { create(:playlist, spotify_id: '6vc3GonSgPXbXmhLg4OtN4') }

      it 'continues calling for data until all tracks have been added to the current_track_data' do
        service.call
        expect(playlist.current_track_data.tracks.count).to eq playlist.song_count
      end
    end
  end
end
