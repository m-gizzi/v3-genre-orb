# frozen_string_literal: true

class Artist < ApplicationRecord
  has_and_belongs_to_many :tracks
  has_and_belongs_to_many :genres

  validates :name, presence: true
  validates :spotify_id, presence: { message: I18n.t('active_record_validations.spotify_id.presence') },
                         uniqueness: { message: I18n.t('active_record_validations.spotify_id.uniqueness') }
end
