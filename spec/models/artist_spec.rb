# frozen_string_literal: true

require 'rails_helper'

describe Artist, type: :model do
  subject(:artist) { create(:artist) }

  shared_context 'with Artists with Genres' do
    let!(:artist1) { create(:artist, spotify_id: generate_spotify_id) }
    let!(:artist2) { create(:artist, spotify_id: generate_spotify_id, genres: [genre_a, genre_b]) }
    let!(:artist3) { create(:artist, spotify_id: generate_spotify_id, genres: [genre_b, genre_c]) }
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

  describe '#to_rspotify_artist', :vcr do
    it 'returns the right artist from Spotify' do
      expect(artist.to_rspotify_artist.id).to eq artist.spotify_id
    end
  end

  describe '.to_rspotify_artists', :vcr do
    let(:artist_ids) do
      %w[
        6GI52t8N5F02MxU0g5U69P
        36hwOoNPgnsKnhoMBYpJrJ
        69VgCcXFV59QuQWEXSTxfK
        12LgviUQ9DbfYJJ9niDWRq
        3nXMZsj1H0F7h9SDUeYNjg
      ]
    end

    before do
      artist_ids.each do |id|
        create(:artist, spotify_id: id)
      end
    end

    it 'returns the right artists from Spotify' do
      expect(described_class.to_rspotify_artists.map(&:id)).to match_array(artist_ids)
    end

    context 'when the method is called on a large number of Artists' do
      let(:artist_ids) do
        %w[
          3qb5O9pLE0urqttdq4CqLS 0K6DXvfMXmF7L4h0P7Ivva 5j2d5CS0sh2LTpFsrKAFcW 2VcT3LFa9zgz333gKf44jM
          0vXLxVov9wThTze1YI6rIU 0v3A74qYtkL8Wjj1rzLe9Z 2vbPZ0xMZiXxUkR744bcoh 3iexGtoBAyCUbxOKeru5py
          5slSOLb4CcoPOgptg4tsxo 4qzeNR1Pjrgu55xYR9foVa 2AqJPIURzQPk72FXeh8LJx 0SsM5OCOiiwycZIO63OT1S
          5jX8L7D6vWHYlNj9k361vI 4L5LykGl5CSopyhoOTP2xb 58PU6MWEroVyXXTXmpzdny 0SEjW4NsEIkiSgpoxLuQCI
          74wzAUjm5ENI8EtWCaEBDz 2d4DsLfaKstHsimzDw0LyM 7HY8lCkyEUSL5jfENlkshV 4js8BDiQwnHLlDmT1shPH7
          5h6tKZX6V9AYYRbvsxZakW 75azd12Swc8yTuOY5lhjMU 3qznYzY3OEo9gewAVrGFHr 0X4yScuctoizdQapaKybMS
          4rSwFTxoQwxwKjeQlSiLP7 7uLXW75DlTRahz2WKJZGeO 2trnx6921S62OeomGmiG01 3xMGQzg5JvqwOU7oaVuKwJ
          2qVuzGuGrGVA0JXOphHn3F 2GOM1BVtYZRNen3IkfOrRJ 4n3WEY09NL7X6zTWNP4XTC 3beAmqA2s5xwxDAIFJwDG9
          5VAsNbws6j873uHN1VKEmZ 6Ej6u8fvyHFFKn5GaQ5cPn 7djT11AqtEBzdME1OGFfxL 2Azc5aV2MqKRb6S3CENEZl
          6YZ98HsiE3oCtQB0E99Qtt 5w09r1HW3Dc8BMYIvqbnnF 63JN4A4IroUvAN1fyWmsHB 0t9i2yNpYr4QGde2gz8YVg
          161AC1AVRkIGIMxyj5djFQ 6eA5XwY5JNBLqm3X8u2AqD 72vSlNssmiyjzCAt4Z61ME 0b05DhI4gD2fNDlqbFBOyt
          2rGVkwUEaofowUjyWnQMXG 3fxdn6mfKvNFJ1Zx37On7W 7wDfZhaCORLgP3K62R3MJK 1I7FVmvisCtSFzmm87mbLR
          6hCsqVHnBo1BVQWuIjRMkL 1BMpbT4eEAJreNQKAdPBiH 31ufWigY0fDQ8p8EJxvaGH 2imgRP2nURSgnz95gLshPF
          0u0iaH7ESuQHoYY06AButU 1D2acYwVzm55CayJwUwqB5 7wkjhjRAaChOE0hMghtlvc 3VvmUsYPzFheK2wJGKcXxp
          0LUkZYSaO60vSGVxgZM5PI 3MUnAJMKx97SfTZYNB2iXY 3qQgY6bwLUYIkxPWTaafHR 7pfZnHTXD8eEUVQdDfPKwN
          7jfErUM4CHGxIaqCEgkxJm 0JC4o7RAl3GNs1MbThyuoD 04dvqs3z04paTr2YeAmpe0 3mp5zzEz1qTq7X5a2yOS2B
          5sM4cZ9MHihs0tbmkiE9n8 3jT2Zl57kYDK5qI8fkl1L9 1YumFgivFXVVg1AKBJKE5e 67CxTr6NMaF4v8X8rxXFIA
          7taR4NVoGObH3v6708KBgV 41kO57U2yrvAWlng1p5g6g 6qokeohfvbaNK1m0VfIEtB
        ]
      end

      it 'does not raise an error' do
        expect { described_class.to_rspotify_artists }.not_to raise_error
      end

      it 'returns the right artists from Spotify' do
        expect(described_class.to_rspotify_artists.map(&:id)).to match_array(artist_ids)
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
