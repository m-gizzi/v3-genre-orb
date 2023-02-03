# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_contexts/with_tracks_with_artists_and_genres'

describe Track, type: :model do
  describe '.with_at_least_one_artist_in_any_genres' do
    include_context 'with Tracks with Artists and Genres'

    it 'can accept a single string as an argument and return any Tracks with at least one Artist in that Genre' do
      expect(described_class.with_at_least_one_artist_in_any_genres(genre_name_matches_some_artists))
        .to(include(track_with_genres).and(exclude(nil_genre_track)))
    end

    it 'can accept a single string in an array and return Tracks with at least one Artist in that Genre' do
      expect(described_class.with_at_least_one_artist_in_any_genres([genre_name_matches_some_artists]))
        .to(include(track_with_genres).and(exclude(nil_genre_track)))
    end

    it 'can accept nil as a single argument and return any Tracks with at least one Artist with no Genres' do
      expect(described_class.with_at_least_one_artist_in_any_genres(nil))
        .to(exclude(track_with_genres).and(include(nil_genre_track)))
    end

    it 'can accept nil as part of an array and return any Tracks with at least one Artist with no Genres' do
      expect(described_class.with_at_least_one_artist_in_any_genres([nil]))
        .to(exclude(track_with_genres).and(include(nil_genre_track)))
    end

    it 'can accept an array and return and Tracks with at least one Artist matching any of those Genres' do
      expect(described_class.with_at_least_one_artist_in_any_genres([genre_name_matches_some_artists, nil]))
        .to(include(track_with_genres).and(include(nil_genre_track)))
    end
  end

  describe '.with_at_least_one_artist_not_in_any_genres' do
    include_context 'with Tracks with Artists and Genres'

    it 'does not include tracks when all their Artists match the passed arg' do
      expect(described_class.with_at_least_one_artist_not_in_any_genres(genre_name_matches_all_artists))
        .to(exclude(track_with_genres).and(include(nil_genre_track)))
    end

    it 'includes tracks when some of their Artists do not match the passed arg' do
      expect(described_class.with_at_least_one_artist_not_in_any_genres(genre_name_matches_some_artists))
        .to(include(track_with_genres).and(include(nil_genre_track)))
    end

    it 'includes tracks when none of their Artists match the passed arg' do
      expect(described_class.with_at_least_one_artist_not_in_any_genres(genre_name_matches_no_artists))
        .to(include(track_with_genres).and(include(nil_genre_track)))
    end

    it 'includes tracks with any artist with a genre if nil is passed' do
      expect(described_class.with_at_least_one_artist_not_in_any_genres(nil))
        .to(include(track_with_genres).and(exclude(nil_genre_track)))
    end

    it 'can accept an array and return any Tracks with at least one Artist that does not match any passed Genres' do
      expect(described_class.with_at_least_one_artist_not_in_any_genres([genre_name_matches_all_artists]))
        .to(exclude(track_with_genres).and(include(nil_genre_track)))
    end
  end

  describe '.with_all_artists_in_any_genres' do
    include_context 'with Tracks with Artists and Genres'

    it 'includes tracks when all their Artists match the passed arg' do
      expect(described_class.with_all_artists_in_any_genres(genre_name_matches_all_artists))
        .to(include(track_with_genres).and(exclude(nil_genre_track)))
    end

    it 'excludes tracks when only some of their Artists match the passed arg' do
      expect(described_class.with_all_artists_in_any_genres(genre_name_matches_some_artists))
        .to(exclude(track_with_genres).and(exclude(nil_genre_track)))
    end

    it 'does not include tracks when none of their Artists match the passed arg' do
      expect(described_class.with_all_artists_in_any_genres(genre_name_matches_no_artists))
        .to(exclude(track_with_genres).and(exclude(nil_genre_track)))
    end

    it 'includes tracks when none of its Artists have a genre if nil is passed' do
      expect(described_class.with_all_artists_in_any_genres(nil))
        .to(exclude(track_with_genres).and(include(nil_genre_track)))
    end

    it 'can accept an array and return any Tracks where all Artists match any passed Genres' do
      expect(described_class.with_all_artists_in_any_genres([genre_name_matches_all_artists]))
        .to(include(track_with_genres).and(exclude(nil_genre_track)))
    end
  end
end
