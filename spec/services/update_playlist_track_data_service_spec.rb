# frozen_string_literal: true

require 'rails_helper'

describe UpdatePlaylistTrackDataService do
  subject(:service) { described_class.new(playlist, track_data) }

  let(:track_data) { TrackDataImport.create!(playlist:) }

  shared_examples 'updating track data' do
    it 'marks the TrackDataImport as complete' do
      expect { service.call }.to change { TrackDataImport.completed.count }.by(1)
    end

    it 'sets the TrackDataImport as the current_track_data for the playlist' do
      service.call
      expect(playlist.current_track_data).to be track_data
    end

    context 'when a track is returned that already exists in the database' do
      before do
        service.call
      end

      it 'does not create a duplicate' do
        expect { service.call }.not_to change(Track, :count)
      end
    end

    it 'creates new Artists from the response' do
      expect { service.call }.to change(Artist, :count)
    end

    context 'when a artist is returned that already exists in the database' do
      before do
        service.call
      end

      it 'does not create a duplicate' do
        expect { service.call }.not_to change(Artist, :count)
      end
    end

    it 'associates all the Artists from the response with their Tracks' do
      service.call
      expect(Track.all.map(&:artists)).to all(be_present)
    end

    it 'associates all the Tracks from the response to the new TrackDataImport' do
      service.call
      expect(playlist.current_track_data.tracks.count).to eq playlist.song_count
    end
  end

  describe '#call with a Playlist passed as an argument' do
    let(:playlist) { create(:playlist) }

    before do
      stub_request(:get, "https://api.spotify.com/v1/playlists/#{playlist.spotify_id}")
        .to_return(status: 200, body: File.read('spec/fixtures/successful_get_playlist.json'))

      stub_request(:get, %r{https://api.spotify.com/v1/playlists/\S{22}/tracks})
        .to_return(status: 200, body: File.read('spec/fixtures/successful_get_twenty_tracks.json'))
    end

    include_examples 'updating track data'

    it 'creates new Tracks from the response' do
      playlist.sync_with_spotify!(playlist.to_rspotify_playlist)
      expect { service.call }.to change(Track, :count).by(playlist.song_count)
    end
  end

  describe '#call with a LikedSongsPlaylist passed as an argument' do
    let(:playlist) { create(:liked_songs_playlist) }

    before do
      stub_request(:get, 'https://api.spotify.com/v1/me/tracks?limit=50&offset=0')
        .to_return(status: 200, body: File.read('spec/fixtures/successful_get_liked_tracks.json'))
    end

    include_examples 'updating track data'

    it 'creates new Tracks from the response' do
      rspotify_user = playlist.user.to_rspotify_user
      playlist.sync_with_spotify!(service.spotify_client.get_liked_tracks(rspotify_user))

      expect { service.call }.to change(Track, :count).by(playlist.song_count)
    end
  end
end
