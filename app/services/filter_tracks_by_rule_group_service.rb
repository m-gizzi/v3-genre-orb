# frozen_string_literal: true

class FilterTracksByRuleGroupService < ApplicationService
  attr_reader :tracks, :rule_group

  def initialize(tracks, rule_group)
    @tracks = tracks
    @rule_group = rule_group
  end

  def call
    case rule_group.criterion
    when 'any_pass'
      tracks_matching_any_artists_genre_rules | tracks_matching_all_artists_genre_rules
    end
  end

  private

  def tracks_matching_any_artists_genre_rules
    any_artists_genres = rule_group.rules.any_artists_genre.pluck(:value)
    tracks.with_at_least_one_artist_in_any_genres(any_artists_genres)
  end

  def tracks_matching_all_artists_genre_rules
    all_artists_genres = rule_group.rules.all_artists_genre.pluck(:value)

    first_query = tracks.with_all_artists_in_any_genres(all_artists_genres.shift).ids
    all_artists_genres.reduce(first_query) { |queries, genre| queries | tracks.with_all_artists_in_any_genres(genre) }
  end
end
