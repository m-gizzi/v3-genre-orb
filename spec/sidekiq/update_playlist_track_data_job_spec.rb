# frozen_string_literal: true

require 'rails_helper'

describe UpdatePlaylistTrackDataJob, type: :job do
  describe '#perform', :vcr do
    shared_examples 'UpdatePlaylistTrackDataJob examples' do
      it 'creates a new TrackData to log the scraped data' do
        expect { described_class.perform_async(playlist.id, playlist.class.to_s) }.to change(TrackData, :count).by(1)
      end

      it 'associates all the Tracks from the response to the new TrackData' do
        described_class.perform_async(playlist.id, playlist.class.to_s)
        expect(playlist.reload.current_track_data.tracks.count).to eq playlist.song_count
      end
    end

    context 'when the playlist passed to the job is a Playlist' do
      let(:playlist) { create(:playlist) }

      include_examples 'UpdatePlaylistTrackDataJob examples'
    end

    context 'when the playlist passed to the job is a LikedSongsPlaylist' do
      let(:playlist) { create(:liked_songs_playlist) }

      include_examples 'UpdatePlaylistTrackDataJob examples'
    end
  end
end
