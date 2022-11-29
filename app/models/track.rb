# frozen_string_literal: true

class Track < ApplicationRecord
  has_and_belongs_to_many :artists
  has_and_belongs_to_many :track_data, class_name: 'TrackData'
  has_many :genres, -> { distinct }, through: :artists

  validates :name, presence: true
  validates :spotify_id, presence: { message: I18n.t('active_record_validations.spotify_id.presence') },
                         uniqueness: { message: I18n.t('active_record_validations.spotify_id.uniqueness') }

  scope :with_at_least_one_artist_in_genre, lambda { |genre|
    left_joins(:genres).where(genres: { name: genre }).distinct
  }
  scope :with_at_least_one_artist_not_in_genre, lambda { |genre|
    joins(:artists).where(artists: Artist.not_in_genre(genre)).distinct
  }
  scope :with_all_artists_in_genre, ->(genre) { where.not(id: Track.with_at_least_one_artist_not_in_genre(genre)) }
end
