# frozen_string_literal: true

class Track < ApplicationRecord
  has_and_belongs_to_many :artists
  has_and_belongs_to_many :track_data, class_name: 'TrackData'
  has_many :genres, -> { distinct }, through: :artists

  validates :name, presence: true
  validates :spotify_id, presence: { message: I18n.t('active_record_validations.spotify_id.presence') },
                         uniqueness: { message: I18n.t('active_record_validations.spotify_id.uniqueness') }

  scope :with_at_least_one_artist_in_any_genres, lambda { |genres|
    left_joins(:genres).where(genres: { name: genres }).distinct
  }
  scope :with_at_least_one_artist_not_in_any_genres, lambda { |genres|
    joins(:artists).where(artists: Artist.not_matching_any_genres(genres)).distinct
  }
  scope :with_all_artists_in_any_genres, lambda { |genres|
    where.not(id: with_at_least_one_artist_not_in_any_genres(genres)).distinct
  }
end
