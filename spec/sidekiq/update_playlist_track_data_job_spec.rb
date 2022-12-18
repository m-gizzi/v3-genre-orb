# frozen_string_literal: true

require 'rails_helper'

describe UpdatePlaylistTrackDataJob, type: :job do
  describe '#perform', :vcr do
    let(:track_data_import) { TrackDataImport.create!(playlist:) }

    shared_examples 'UpdatePlaylistTrackDataJob examples' do
      it 'associates all the Tracks from the response to the new TrackDataImport' do
        described_class.perform_async(playlist.id, playlist.class.to_s, track_data_import.id)
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
