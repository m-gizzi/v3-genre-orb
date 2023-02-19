# frozen_string_literal: true

require 'rails_helper'

describe UpdateArtistsGenresJob, type: :job do
  let(:artist) { create(:artist, spotify_id: '0Wxy5Qka8BN9crcFkiAxSR') }

  describe '#perform' do
    before do
      stub_request(:get, "https://api.spotify.com/v1/artists?ids=#{artist.spotify_id}")
        .to_return(status: 200, body: File.read('spec/fixtures/successful_get_single_artist.json'))
    end

    it 'creates new Genres from the response' do
      expect { described_class.perform_async(artist.id) }.to change(Genre, :count)
    end
  end
end
