# frozen_string_literal: true

require 'spotify_client'

class Playlist < ApplicationRecord
  belongs_to :user
  has_many :track_data, dependent: :destroy, class_name: 'TrackData'

  validates :name, presence: true
  validates :spotify_id, presence: { message: I18n.t('active_record_validations.spotify_id.presence') },
                         uniqueness: { message: I18n.t('active_record_validations.spotify_id.uniqueness') }

  def to_rspotify_playlist
    rspotify_playlist = SpotifyClient.get_rspotify_playlist_by_id(spotify_id)

    assign_attributes(song_count: rspotify_playlist.total, name: rspotify_playlist.name)
    save! if changed?
    rspotify_playlist
  end

  def current_track_data
    track_data.last
  end

  def update_track_data!
    UpdatePlaylistTrackDataService.call(self)
  end
end
