# frozen_string_literal: true

require 'rails_helper'

describe BatchUpdateArtistsGenresJob do
  let(:artist_ids) { Array.new(151) { generate_spotify_id } }

  before do
    build_list(:artist, 151).each_with_index do |artist, i|
      artist.spotify_id = artist_ids[i]
      artist.save!
    end
  end

  describe '#perform' do
    it 'enqueues one UpdateArtistsGenresJob for every 50 artists' do
      expect do
        described_class.perform_async
        described_class.drain
      end.to change(UpdateArtistsGenresJob.jobs, :size).by(4)
    end

    it 'does not enqueue any jobs with more than 50 artist_ids' do
      described_class.perform_async
      described_class.drain
      expect(UpdateArtistsGenresJob.jobs.map { |job| job['args'].flatten.count }).to all(be <= 50)
    end
  end
end
