# frozen_string_literal: true

require 'rails_helper'

describe FetchArtistFallbackGenresService do
  subject(:service) { described_class.new(artist) }

  let(:artist) { create(:artist, spotify_id: '0Wxy5Qka8BN9crcFkiAxSR') }

  describe '#call', :vcr do
    it 'returns an array of Genres' do
      expect(service.call).to all(be_a(Genre))
    end

    it 'does not save any Genres it initializes' do
      expect(service.call.pluck(:id)).to all(be_nil)
    end

    context 'when a Genre returned by Spotify already exists in the database' do
      let!(:genre) { create(:genre) }

      it 'includes the Genres from the database in its results' do
        expect(service.call).to include(genre)
      end
    end
  end
end
