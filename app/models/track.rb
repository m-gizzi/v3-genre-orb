# frozen_string_literal: true

class Track < ApplicationRecord
  has_and_belongs_to_many :artists
  has_and_belongs_to_many :track_data, class_name: 'TrackData'

  validates :name, presence: true
  validates :spotify_id, presence: { message: I18n.t('active_record_validations.spotify_id.presence') },
                         uniqueness: { message: I18n.t('active_record_validations.spotify_id.uniqueness') }

  scope :with_at_least_one_artist_in_genre, lambda { |genre|
    joins(:artists).where(artists: Artist.in_genre(genre)).distinct
  }
end
