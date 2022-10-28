# frozen_string_literal: true

class User < ApplicationRecord
  has_one :oauth_credential, dependent: :destroy
  has_one :liked_songs_playlist, dependent: :destroy
  has_many :playlists, dependent: :destroy
  has_many :api_logs, dependent: :destroy

  validates :full_name, presence: true
  validates :spotify_id, presence: { message: I18n.t('active_record_validations.spotify_id.presence') },
                         uniqueness: { message: I18n.t('active_record_validations.spotify_id.uniqueness') }
end
