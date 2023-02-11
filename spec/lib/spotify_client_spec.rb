# frozen_string_literal: true

require 'rails_helper'
require 'spotify_client'
require 'support/shared_contexts/with_a_stubbed_retryable_error'

describe SpotifyClient do
  subject(:client) { described_class.new }

  describe '#get_playlist_by_id' do
    let(:playlist_id) { generate_spotify_id }

    before do
      stub_request(:get, "https://api.spotify.com/v1/playlists/#{playlist_id}")
        .to_return(status: 200, body: File.read('spec/fixtures/successful_get_playlist.json'))
    end

    it 'returns an RSpotify::Playlist' do
      expect(client.get_playlist_by_id(playlist_id)).to be_a(RSpotify::Playlist)
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

      it 'returns an RSpotify::Playlist' do
        expect(client.get_playlist_by_id(playlist_id)).to be_a(RSpotify::Playlist)
      end
    end
  end

  describe '#get_artists_by_ids' do
    let(:artist_ids) { Array.new(5) { generate_spotify_id } }

    before do
      stub_request(:get, %r{https://api.spotify.com/v1/artists}).with do |request|
        request.uri.query_values['ids'].split(',').count == 5
      end.to_return(
        status: 200,
        body: File.read('spec/fixtures/successful_get_five_artists.json')
      )
    end

    it 'returns an array of RSpotify::Artists' do
      expect(client.get_artists_by_ids(artist_ids)).to all(be_a(RSpotify::Artist))
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

      it 'returns an array of RSpotify::Artists' do
        expect(client.get_artists_by_ids(artist_ids)).to all(be_a(RSpotify::Artist))
      end
    end
  end

  describe '#get_related_artists' do
    let(:artist) { create(:artist) }
    let(:rspotify_artist) { artist.to_rspotify_artist }

    before do
      stub_request(:get, "https://api.spotify.com/v1/artists?ids=#{artist.spotify_id}").to_return(
        status: 200,
        body: File.read('spec/fixtures/successful_get_single_artist.json')
      )
      stub_request(:get, %r{https://api.spotify.com/v1/artists/\S{22}/related-artists}).to_return(
        status: 200,
        body: File.read('spec/fixtures/successful_get_related_artists.json')
      )
    end

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

    before do
      stub_request(:get, "https://api.spotify.com/v1/playlists/#{playlist.spotify_id}")
        .to_return(status: 200, body: File.read('spec/fixtures/successful_get_playlist.json'))
      stub_request(:get, %r{https://api.spotify.com/v1/playlists/\S{22}/tracks})
        .to_return(status: 200, body: File.read('spec/fixtures/successful_get_twenty_tracks.json'))
    end

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

    before do
      stub_request(:get, %r{https://api.spotify.com/v1/me/tracks})
        .to_return(status: 200, body: File.read('spec/fixtures/successful_get_liked_tracks.json'))
    end

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
end
