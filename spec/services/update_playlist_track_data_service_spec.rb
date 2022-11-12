# frozen_string_literal: true

require 'rails_helper'

describe UpdatePlaylistTrackDataService do
  subject(:service) { described_class.new(playlist) }

  shared_examples 'updating track data' do
    it 'marks the TrackData as complete' do
      expect { service.call }.to change { TrackData.completed.count }.by(1)
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

    it 'associates all the Tracks from the response to the new TrackData' do
      service.call
      expect(playlist.current_track_data.tracks.count).to eq playlist.song_count
    end
  end

  describe '#call with a Playlist passed as an argument', :vcr do
    let(:playlist) { create(:playlist) }

    include_examples 'updating track data'

    it 'creates new Tracks from the response' do
      playlist.sync_with_spotify!(playlist.to_rspotify_playlist)
      expect { service.call }.to change(Track, :count).by(playlist.song_count)
    end

    context "when multiple calls must be made to fetch all the playlist's tracks" do
      subject(:service_call) { described_class.new(playlist, self_queuing:).call }

      let(:playlist) { create(:playlist, :many_tracks) }

      shared_examples 'updating track data for long playlists' do
        it 'continues calling for data until all tracks have been added to the current_track_data' do
          service_call
          expect(playlist.current_track_data.tracks.count).to eq playlist.song_count
        end

        it 'marks the TrackData as complete' do
          expect { service_call }.to change { TrackData.completed.count }.by(1)
        end
      end

      context 'when the self_queuing method is synchronous' do
        let(:self_queuing) { 'synchronous' }

        include_examples 'updating track data for long playlists'
      end

      context 'when the self_queuing method is asynchronous' do
        subject(:service_call) do
          Sidekiq::Testing.inline! do
            described_class.new(playlist, self_queuing:).call
          end
        end

        let(:self_queuing) { 'asynchronous' }

        include_examples 'updating track data for long playlists'
      end
    end
  end

  describe '#call with a LikedSongsPlaylist passed as an argument', :vcr do
    let(:playlist) { create(:liked_songs_playlist) }

    include_examples 'updating track data'

    it 'creates new Tracks from the response' do
      rspotify_user = playlist.user.to_rspotify_user
      playlist.sync_with_spotify!(service.spotify_client.get_liked_tracks(rspotify_user))

      expect { service.call }.to change(Track, :count).by(playlist.song_count)
    end
  end
end
