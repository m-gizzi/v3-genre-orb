# frozen_string_literal: true

require 'rails_helper'

describe BatchUpdateArtistsFallbackGenresJob do
  let(:genre) { create(:genre) }
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
    build_list(:artist, 5).each_with_index do |artist, i|
      artist.spotify_id = artist_ids[i]
      artist.save!
    end

    Artist.last.genres = [genre]
  end

  describe '#perform' do
    it 'enqueues an UpdateArtistFallbackGenresJob for each eligible Artist' do
      expect do
        described_class.perform_async
        described_class.drain
      end.to change(UpdateArtistFallbackGenresJob.jobs, :size).by(4)
    end

    it 'does not enqueue a job for an Artist that already has Genres associated' do
      described_class.perform_async
      described_class.drain
      expect(UpdateArtistFallbackGenresJob.jobs.pluck('args')).not_to include(Artist.last.id)
    end
  end
end
