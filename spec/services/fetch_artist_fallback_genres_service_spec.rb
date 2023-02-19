# frozen_string_literal: true

require 'rails_helper'

describe FetchArtistFallbackGenresService do
  subject(:service) { described_class.new(artist) }

  let(:artist) { create(:artist) }

  before do
    stub_request(:get, "https://api.spotify.com/v1/artists?ids=#{artist.spotify_id}")
      .to_return(status: 200, body: File.open('./spec/fixtures/successful_get_single_artist.json'))

    stub_request(:get, 'https://api.spotify.com/v1/artists/0Wxy5Qka8BN9crcFkiAxSR/related-artists')
      .to_return(status: 200, body: File.open('./spec/fixtures/successful_get_related_artists.json'))
  end

  describe '#call' do
    it 'returns an array of Genres' do
      expect(service.call).to all(be_a(Genre))
    end

    it 'does not save any Genres it initializes' do
      expect(service.call.pluck(:id)).to all(be_nil)
    end

    context 'when a Genre returned by Spotify already exists in the database' do
      let!(:genre) { create(:genre, name: 'rhythm and blues') }

      it 'includes the Genres from the database in its results' do
        expect(service.call).to include(genre)
      end
    end
  end
end
