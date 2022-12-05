# frozen_string_literal: true

class Rule < ApplicationRecord
  belongs_to :rule_group
  has_one :smart_playlist, through: :rule_group
  has_one :playlist, through: :smart_playlist
  has_one :user, through: :playlist

  enum condition: {
    any_artists_genre: 'any_artists_genre',
    all_artists_genre: 'all_artists_genre'
  }

  def tracks_that_pass_condition
    case condition
    when 'any_artists_genre'
      user.current_tracks.with_at_least_one_artist_in_any_genres(value)
    when 'all_artists_genre'
      user.current_tracks.with_all_artists_in_genre(value)
    end
  end
end
