# frozen_string_literal: true

class User < ApplicationRecord
  has_one :oauth_credential, dependent: :destroy
  has_one :liked_songs_playlist, dependent: :destroy
  has_many :playlists, dependent: :destroy

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
    Track.where(id: current_playlist_track_ids)
  end

  private

  def current_playlist_track_ids
    all_playlists = playlists.includes(current_track_data: :tracks).to_a << liked_songs_playlist

    all_playlists.flat_map { |playlist| playlist&.current_track_data&.tracks&.ids }.compact.uniq
  end
end
