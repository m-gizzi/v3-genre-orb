# frozen_string_literal: true

class User < ApplicationRecord
  has_one :oauth_credential, dependent: :destroy
  has_one :liked_songs_playlist, dependent: :destroy

  has_many :playlists, dependent: :destroy
  has_many :playlists_current_track_data_imports, through: :playlists, as: :playlist
  has_many :current_track_data, through: :playlists_current_track_data_imports, source: :track_data_import

  has_one :liked_songs_current_track_data_imports,
          through: :liked_songs_playlist,
          as: :playlist,
          source: :playlists_current_track_data_import
  has_one :current_liked_songs_track_data, through: :liked_songs_current_track_data_imports, source: :track_data_import

  validates :full_name, presence: true
  validates :spotify_id, presence: { message: I18n.t('active_record_validations.spotify_id.presence') },
                         uniqueness: { message: I18n.t('active_record_validations.spotify_id.uniqueness') }

  class UnauthorizedError < StandardError; end

  def to_rspotify_user
    raise UnauthorizedError, 'User has not granted this app access to their Spotify account.' unless oauth_credential

    RSpotify::User.new(
      {
        credentials: {
          token: oauth_credential.decrypted_access_token,
          refresh_token: oauth_credential.decrypted_refresh_token
        },
        info: { id: spotify_id }
      }.with_indifferent_access
    )
  end

  def current_tracks
    current_playlist_track_ids = current_track_data.includes(:tracks).flat_map(&:track_ids)
    liked_songs_track_ids = current_liked_songs_track_data.track_ids
    ids = current_playlist_track_ids | liked_songs_track_ids

    Track.where(id: ids)
  end
end
