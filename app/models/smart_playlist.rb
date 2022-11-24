# frozen_string_literal: true

class SmartPlaylist < ApplicationRecord
  SPOTIFY_PLAYLIST_TRACK_LIMIT = 10_000

  belongs_to :playlist

  validates :track_limit, numericality: { less_than_or_equal_to: SPOTIFY_PLAYLIST_TRACK_LIMIT }
end
