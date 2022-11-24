# frozen_string_literal: true

class SmartPlaylist < ApplicationRecord
  SPOTIFY_PLAYLIST_TRACK_LIMIT = 10_000

  belongs_to :playlist
  has_one :rule_group, dependent: :destroy, required: true

  validates :track_limit, numericality: { less_than_or_equal_to: SPOTIFY_PLAYLIST_TRACK_LIMIT }

  before_validation :build_rule_group, if: proc { |smart_playlist| smart_playlist.rule_group.nil? }
end
