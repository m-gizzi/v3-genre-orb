# frozen_string_literal: true

require 'rails_helper'

describe UpdateArtistFallbackGenresJob, type: :job do
  describe '#perform' do
    let(:artist) { create(:artist, spotify_id: artist_id) }
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
      expect { described_class.perform_async(artist.id) }.to change { artist.genres.pluck(:name) }.to(genre_names_array)
    end
  end
end
