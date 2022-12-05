# frozen_string_literal: true

require 'rails_helper'

describe Track, type: :model do
  describe '.with_at_least_one_artist_in_genre' do
    include_context 'with Tracks with Artists and Genres'

    it 'includes tracks when all their Artists match the passed arg' do
      expect(described_class.with_at_least_one_artist_in_genre(genre_name_matches_all_artists))
        .to(include(track_with_genres).and(exclude(nil_genre_track)))
    end

    it 'includes tracks when some of their Artists match the passed arg' do
      expect(described_class.with_at_least_one_artist_in_genre(genre_name_matches_some_artists))
        .to(include(track_with_genres).and(exclude(nil_genre_track)))
    end

    it 'does not include tracks when none of their Artists match the passed arg' do
      expect(described_class.with_at_least_one_artist_in_genre(genre_name_matches_no_artists))
        .to(exclude(track_with_genres).and(exclude(nil_genre_track)))
    end

    it 'includes tracks with any artist with no genre if nil is passed' do
      expect(described_class.with_at_least_one_artist_in_genre(nil))
        .to(exclude(track_with_genres).and(include(nil_genre_track)))
    end
  end

  describe '.with_at_least_one_artist_not_in_genre' do
    include_context 'with Tracks with Artists and Genres'

    it 'does not include tracks when all their Artists match the passed arg' do
      expect(described_class.with_at_least_one_artist_not_in_genre(genre_name_matches_all_artists))
        .to(exclude(track_with_genres).and(include(nil_genre_track)))
    end

    it 'includes tracks when some of their Artists do not match the passed arg' do
      expect(described_class.with_at_least_one_artist_not_in_genre(genre_name_matches_some_artists))
        .to(include(track_with_genres).and(include(nil_genre_track)))
    end

    it 'includes tracks when none of their Artists match the passed arg' do
      expect(described_class.with_at_least_one_artist_not_in_genre(genre_name_matches_no_artists))
        .to(include(track_with_genres).and(include(nil_genre_track)))
    end

    it 'includes tracks with any artist with a genre if nil is passed' do
      expect(described_class.with_at_least_one_artist_not_in_genre(nil))
        .to(include(track_with_genres).and(exclude(nil_genre_track)))
    end
  end

  describe '.with_all_artists_in_genre' do
    include_context 'with Tracks with Artists and Genres'

    it 'includes tracks when all their Artists match the passed arg' do
      expect(described_class.with_all_artists_in_genre(genre_name_matches_all_artists))
        .to(include(track_with_genres).and(exclude(nil_genre_track)))
    end

    it 'excludes tracks when only some of their Artists match the passed arg' do
      expect(described_class.with_all_artists_in_genre(genre_name_matches_some_artists))
        .to(exclude(track_with_genres).and(exclude(nil_genre_track)))
    end

    it 'does not include tracks when none of their Artists match the passed arg' do
      expect(described_class.with_all_artists_in_genre(genre_name_matches_no_artists))
        .to(exclude(track_with_genres).and(exclude(nil_genre_track)))
    end

    it 'includes tracks when none of its Artists have a genre if nil is passed' do
      expect(described_class.with_all_artists_in_genre(nil))
        .to(exclude(track_with_genres).and(include(nil_genre_track)))
    end
  end
end