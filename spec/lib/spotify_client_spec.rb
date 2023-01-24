# frozen_string_literal: true

require 'rails_helper'
require 'spotify_client'

describe SpotifyClient, :vcr do
  subject(:client) { described_class.new }

  describe '#get_playlist_by_id' do
    let(:playlist_id) { '3IlD894HSWDF8YlkCP25Sq' }

    it 'returns the correct playlist' do
      expect(client.get_playlist_by_id(playlist_id).id).to eq playlist_id
    end

    context 'when a 429 error is raised' do
      include_context 'with a stubbed retryable error' do
        let(:error_class) { RestClient::TooManyRequests }
        let(:recipient) { RSpotify::Playlist }
        let(:message) { :find_by_id }
      end

      it 'reattempts the call that errored out' do
        client.get_playlist_by_id(playlist_id)
        expect(RSpotify::Playlist).to have_received(:find_by_id).twice
      end

      it 'returns the correct playlist' do
        expect(client.get_playlist_by_id(playlist_id).id).to eq playlist_id
      end
    end
  end

  describe '#get_artists_by_ids' do
    let(:artist_ids) { %w[1iNbNgr25BaS5e9a8xUZ9J 3ggwAqZD3lyT2sbovlmfQY] }

    it 'returns an array with the correct artists in it' do
      expect(client.get_artists_by_ids(artist_ids).map(&:id)).to match_array artist_ids
    end

    context 'when it is called with too many artist_ids' do
      let(:too_many_artist_ids) { Array.new(51) { generate_spotify_id } }

      it 'raises an error' do
        expect { client.get_artists_by_ids(too_many_artist_ids) }.to raise_error(ArgumentError)
      end
    end

    context 'when a 429 error is raised' do
      include_context 'with a stubbed retryable error' do
        let(:error_class) { RestClient::TooManyRequests }
        let(:recipient) { RSpotify::Artist }
        let(:message) { :find }
      end

      it 'reattempts the call that errored out' do
        client.get_artists_by_ids(artist_ids)
        expect(RSpotify::Artist).to have_received(:find).twice
      end

      it 'returns an array with the correct artists in it' do
        expect(client.get_artists_by_ids(artist_ids).map(&:id)).to match_array artist_ids
      end
    end
  end

  describe '#get_related_artists' do
    let(:artist) { create(:artist, spotify_id: '0Wxy5Qka8BN9crcFkiAxSR') }
    let(:rspotify_artist) { artist.to_rspotify_artist }

    it 'returns the artist\'s related artists' do
      expect(client.get_related_artists(rspotify_artist)).to all(be_a(RSpotify::Artist))
    end

    context 'when a 429 error is raised' do
      include_context 'with a stubbed retryable error' do
        let(:error_class) { RestClient::TooManyRequests }
        let(:recipient) { rspotify_artist }
        let(:message) { :related_artists }
      end

      it 'reattempts the call that errored out' do
        client.get_related_artists(rspotify_artist)
        expect(rspotify_artist).to have_received(:related_artists).twice
      end

      it 'returns the artist\'s related artists' do
        expect(client.get_related_artists(rspotify_artist)).to all(be_a(RSpotify::Artist))
      end
    end
  end

  describe '#get_tracks' do
    let(:playlist) { create(:playlist) }
    let(:rspotify_playlist) { playlist.to_rspotify_playlist }

    it 'returns the playlist\'s raw track data' do
      expect(client.get_tracks(rspotify_playlist)).to be_a Responses::GetTracks
    end

    context 'when a 429 error is raised' do
      include_context 'with a stubbed retryable error' do
        let(:error_class) { RestClient::TooManyRequests }
        let(:recipient) { rspotify_playlist }
        let(:message) { :tracks }
      end

      it 'reattempts the call that errored out' do
        client.get_tracks(rspotify_playlist)
        expect(rspotify_playlist).to have_received(:tracks).twice
      end

      it 'returns the playlist\'s raw track data' do
        expect(client.get_tracks(rspotify_playlist)).to be_a Responses::GetTracks
      end
    end
  end

  describe '#get_liked_tracks' do
    let(:playlist) { create(:liked_songs_playlist) }
    let(:rspotify_user) { playlist.user.to_rspotify_user }

    it 'returns the playlist\'s raw track data' do
      expect(client.get_liked_tracks(rspotify_user)).to be_a Responses::GetTracks
    end

    context 'when a 429 error is raised' do
      include_context 'with a stubbed retryable error' do
        let(:error_class) { RestClient::TooManyRequests }
        let(:recipient) { rspotify_user }
        let(:message) { :saved_tracks }
      end

      it 'reattempts the call that errored out' do
        client.get_liked_tracks(rspotify_user)
        expect(rspotify_user).to have_received(:saved_tracks).twice
      end

      it 'returns the playlist\'s raw track data' do
        expect(client.get_liked_tracks(rspotify_user)).to be_a Responses::GetTracks
      end
    end
  end

  describe '#add_tracks_to_playlist!' do
    let(:playlist) { create(:playlist, :with_authorized_user) }
    let(:rspotify_playlist) { playlist.to_rspotify_playlist }
    let(:track_uris) { %w[spotify:track:1JcwHjETNNbUH0yfrc9w9n spotify:track:3iXq36mZaO2QpWO2vOUDYz] }

    before do
      # This needs to be called in order to authorize this API call
      playlist.user.to_rspotify_user
    end

    it 'adds the tracks to the playlist' do
      expect { client.add_tracks_to_playlist!(rspotify_playlist, track_uris) }
        .to change { playlist.to_rspotify_playlist.total }.by(track_uris.count)
    end

    context 'when a 429 error is raised' do
      include_context 'with a stubbed retryable error' do
        let(:error_class) { RestClient::TooManyRequests }
        let(:recipient) { rspotify_playlist }
        let(:message) { :add_tracks! }
      end

      it 'reattempts the call that errored out' do
        client.add_tracks_to_playlist!(rspotify_playlist, track_uris)
        expect(rspotify_playlist).to have_received(:add_tracks!).twice
      end

      it 'adds the tracks to the playlist' do
        expect { client.add_tracks_to_playlist!(rspotify_playlist, track_uris) }
          .to change { playlist.to_rspotify_playlist.total }.by(track_uris.count)
      end
    end
  end

  # describe '#remove_tracks_from_playlist!' do
  #   let(:playlist) { create(:playlist) }
  #   let(:rspotify_playlist) { playlist.to_rspotify_playlist }

  #   it 'removes the tracks from the playlist' do
  #     client.remove_tracks_from_playlist!(rspotify_playlist, track_uris)
  #   end
  # end
end
