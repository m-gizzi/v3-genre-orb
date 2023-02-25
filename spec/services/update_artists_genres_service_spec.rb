# frozen_string_literal: true

require 'rails_helper'

describe UpdateArtistsGenresService do
  subject(:service) { described_class.new(artists) }

  let(:artists) { Artist.all }
  let!(:artist) { create(:artist, spotify_id: '0Wxy5Qka8BN9crcFkiAxSR', name: 'Wrong Name') }

  describe '#call' do
    before do
      stub_request(:get, "https://api.spotify.com/v1/artists?ids=#{artist.spotify_id}")
        .to_return(status: 200, body: File.read('spec/fixtures/successful_get_single_artist.json'))
    end

    it 'updates the name of the Artist if it is different from what Spotify returns' do
      expect { service.call }.to(change { artist.reload.name })
    end

    it 'creates new Genres from the response' do
      expect { service.call }.to change(Genre, :count)
    end

    context 'when a genre is returned that already exists in the database' do
      it 'does not create a duplicate' do
        service.call
        expect { service.call }.not_to change(Genre, :count)
      end
    end

    it 'associates all the Genres from the response with their Artists' do
      expect { service.call }.to(change { artist.reload.genres.present? })
    end
  end
end
