# frozen_string_literal: true

require 'rails_helper'

describe Artist, type: :model do
  subject(:artist) { create(:artist) }

  shared_context 'with Artists with Genres' do
    let!(:artist1) { create(:artist) }
    let!(:artist2) { create(:artist, genres: [genre_a, genre_b]) }
    let!(:artist3) { create(:artist, genres: [genre_b, genre_c]) }
    let(:genre_a) { create(:genre, name: 'A') }
    let(:genre_b) { create(:genre, name: 'B') }
    let(:genre_c) { create(:genre, name: 'C') }
  end

  describe '.matching_any_genres' do
    include_context 'with Artists with Genres'

    it 'can accept a single string as an argument and return any Artists matching that Genre' do
      expect(described_class.matching_any_genres('A')).to include artist2
    end

    it 'can accept a single string in an array and return any Artists matching that Genre' do
      expect(described_class.matching_any_genres(['A'])).to include artist2
    end

    it 'can accept an array of genres and return any Artists matching any of the Genres' do
      expect(described_class.matching_any_genres([nil, 'B'])).to match_array([artist1, artist2, artist3])
    end

    it 'can accept nil as a single argument and return any Artists with no Genres' do
      expect(described_class.matching_any_genres(nil)).to include artist1
    end

    it 'can accept nil as part of an array and return any Artists with no Genres' do
      expect(described_class.matching_any_genres([nil])).to include artist1
    end
  end

  describe '.not_matching_any_genres' do
    include_context 'with Artists with Genres'

    it "can accept a single string as an argument and return any Artists that don't match that Genre" do
      expect(described_class.not_matching_any_genres('A')).to match_array([artist1, artist3])
    end

    it "can accept a single string in an array and return any Artists that don't match that Genre" do
      expect(described_class.not_matching_any_genres(['A'])).to match_array([artist1, artist3])
    end

    it "can accept an array of genres and return any Artists that don't match any of the Genres" do
      expect(described_class.not_matching_any_genres([nil, 'A'])).to match_array([artist3])
    end

    it 'can accept nil as a single argument and return any Artists with genres' do
      expect(described_class.not_matching_any_genres(nil)).to match_array([artist2, artist3])
    end

    it 'can accept nil as part of an array and return any Artists with genres' do
      expect(described_class.not_matching_any_genres([nil])).to match_array([artist2, artist3])
    end
  end

  describe '.matching_all_genres' do
    include_context 'with Artists with Genres'

    it 'can accept an array of strings and return Artists that match all of the Genres' do
      expect(described_class.matching_all_genres(%w[A B])).to match_array([artist2])
    end
  end

  describe '.not_matching_all_genres' do
    include_context 'with Artists with Genres'

    it 'can accept an array of strings and returns the negation of .matching_all_genres' do
      expect(described_class.not_matching_all_genres(%w[A B])).to match_array([artist1, artist3])
    end
  end

  describe '#to_rspotify_artist' do
    subject(:artist) { create(:artist) }

    before do
      stub_request(:get, "https://api.spotify.com/v1/artists?ids=#{artist.spotify_id}")
        .to_return(status: 200, body: File.open('./spec/fixtures/successful_get_single_artist.json'))
    end

    it 'returns a single RSpotify::Artist' do
      expect(artist.to_rspotify_artist).to be_a RSpotify::Artist
    end
  end

  describe '.to_rspotify_artists' do
    let(:number_of_artists) { 5 }

    before do
      create_list(:artist, number_of_artists)

      stub_request(:get, %r{/api.spotify.com/v1/artists}).with do |request|
        request.uri.query_values['ids'].split(',').count == 5
      end.to_return(
        status: 200,
        body: File.open('./spec/fixtures/successful_get_five_artists.json')
      )
    end

    it 'returns an array of RSpotify::Artists' do
      expect(described_class.to_rspotify_artists).to all(be_a RSpotify::Artist)
    end

    it 'returns the correct number of RSpotify::Artists' do
      expect(described_class.to_rspotify_artists.count).to eq number_of_artists
    end

    context 'when the method is called on a large number of Artists' do
      let(:number_of_artists) { 60 }

      before do
        stub_request(:get, %r{/api.spotify.com/v1/artists}).with do |request|
          request.uri.query_values['ids'].split(',').count == 50
        end.to_return(
          status: 200,
          body: File.open('./spec/fixtures/successful_get_fifty_artists.json')
        )
        stub_request(:get, %r{/api.spotify.com/v1/artists}).with do |request|
          request.uri.query_values['ids'].split(',').count == 10
        end.to_return(
          status: 200,
          body: File.open('./spec/fixtures/successful_get_ten_artists.json')
        )
      end

      it 'does not raise an error' do
        expect { described_class.to_rspotify_artists }.not_to raise_error
      end

      it 'returns an array of RSpotify::Artists' do
        expect(described_class.to_rspotify_artists).to all(be_a RSpotify::Artist)
      end

      it 'returns the correct number of RSpotify::Artists' do
        expect(described_class.to_rspotify_artists.count).to eq number_of_artists
      end
    end
  end

  describe '#sync_fallback_genres!' do
    subject(:artist) { create(:artist, spotify_id: artist_id) }

    let(:artist_id) { 'test_artist_id' }
    let(:genre_names_array) { ['deep euro house', 'german house', 'minimal techno', 'tech house'] }

    before do
      stub_request(:get, "https://api.spotify.com/v1/artists?ids=#{artist_id}").to_return(
        status: 200,
        body: { 'artists' => [{ 'id' => artist_id }] }.to_json
      )

      stub_request(:get, "https://api.spotify.com/v1/artists/#{artist_id}/related-artists").to_return(
        status: 200,
        body: { 'artists' => [{ 'genres' => genre_names_array }] }.to_json
      )
    end

    it 'associates the Artist with all of the Genres returned by Spotify' do
      artist.sync_fallback_genres!
      expect(artist.genres.pluck(:name)).to match_array(genre_names_array)
    end

    it 'marks all Genres associated as being fallback Genres' do
      artist.sync_fallback_genres!
      expect(artist.artists_genres.pluck(:fallback_genre)).to all(be true)
    end

    context 'when the artist already has genres associated with it that are not fallback genres' do
      let(:genre) { create(:genre) }

      before do
        artist.genres = [genre]
      end

      it 'does not make any API calls' do
        artist.sync_fallback_genres!
        expect(a_request(:any, %r{/api.spotify.com/v1/})).not_to have_been_made
      end

      it 'does not change any associations of the Artist' do
        expect { artist.sync_fallback_genres! }.not_to change(artist, :genres)
      end
    end
  end
end
