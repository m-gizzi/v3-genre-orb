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
      track_ids_matching_any_artists_genre_rules | track_ids_matching_all_artists_genre_rules
    end
  end

  private

  def track_ids_matching_any_artists_genre_rules
    any_artists_genres = rule_group.rules.any_artists_genre.pluck(:value)
    tracks.with_at_least_one_artist_in_any_genres(any_artists_genres).ids
  end

  def track_ids_matching_all_artists_genre_rules
    all_artists_genres = rule_group.rules.all_artists_genre.pluck(:value)
    return [] if all_artists_genres.blank?

    first_query = tracks.with_all_artists_in_any_genres(all_artists_genres.shift).ids

    all_artists_genres.reduce(first_query) do |queries, genre|
      queries | tracks.with_all_artists_in_any_genres(genre).ids
    end
  end
end
