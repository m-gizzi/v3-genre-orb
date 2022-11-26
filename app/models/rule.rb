# frozen_string_literal: true

class Rule < ApplicationRecord
  belongs_to :rule_group

  enum condition: {
    any_artists_genre: 'any_artists_genre',
    all_artists_genre: 'all_artists_genre'
  }

  def tracks_that_pass_condition
    case condition
    when 'any_artists_genre'
      Track.with_at_least_one_artist_in_genre(value)
    when 'all_artists_genre'
      Track.with_all_artists_in_genre(value)
    end
  end
end
