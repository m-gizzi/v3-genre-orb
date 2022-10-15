# frozen_string_literal: true

class ArtistsGenre < ApplicationRecord
  belongs_to :artist
  belongs_to :genre

  validates :artist_id, uniqueness: {
    scope: :genre_id,
    message: I18n.t('active_record_validations.artists_genres.uniqueness')
  }
end
