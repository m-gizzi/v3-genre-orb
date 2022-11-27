# frozen_string_literal: true

require 'rails_helper'

describe Track, type: :model do
  shared_context 'when testing Track scopes' do
    let(:track) { create(:track, artists: [artist1, artist2]) }
    let(:artist1) { create(:artist, spotify_id: generate_spotify_id, genres: [genre_a, genre_b]) }
    let(:artist2) { create(:artist, spotify_id: generate_spotify_id, genres: [genre_a]) }
    let(:genre_a) { create(:genre, name: 'A') }
    let(:genre_b) { create(:genre, name: 'B') }
  end

  describe '.with_at_least_one_artist_in_genre' do
    include_context 'when testing Track scopes'

    context "when at least one of the Track's Artists is in the passed genre" do
      it 'includes the Track' do
        expect(described_class.with_at_least_one_artist_in_genre('A')).to include track
      end
    end

    context "when none of the Track's Artists is in the passed genre" do
      it 'does not include the Track' do
        expect(described_class.with_at_least_one_artist_in_genre('Z')).not_to include track
      end
    end
  end

  describe '.with_at_least_one_artist_not_in_genre' do
    include_context 'when testing Track scopes'

    context "when at least one of the Track's Artists is not in the passed genre" do
      it 'includes the Track' do
        expect(described_class.with_at_least_one_artist_not_in_genre('Z')).to include track
      end
    end

    context "when all of the Track's Artists are in the passed genre" do
      it 'does not include the Track' do
        expect(described_class.with_at_least_one_artist_not_in_genre('A')).not_to include track
      end
    end
  end

  describe '.with_all_artists_in_genre' do
    include_context 'when testing Track scopes'

    context "when all of the Track's Artists are in the passed genre" do
      it 'includes the Track' do
        expect(described_class.with_all_artists_in_genre('A')).to include track
      end
    end

    context "when at least one of the Track's Artists is not in the passed genre" do
      it 'does not include the Track' do
        expect(described_class.with_all_artists_in_genre('B')).not_to include track
      end
    end
  end
end
