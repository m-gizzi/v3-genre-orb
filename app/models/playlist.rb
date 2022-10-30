# frozen_string_literal: true

require 'has_spotify_client'

class Playlist < ApplicationRecord
  include HasSpotifyClient

  belongs_to :user
  has_many :track_data, dependent: :destroy, class_name: 'TrackData'
  has_one :current_track_data,
          -> { where(scraping_status: 'completed').order(created_at: :desc) },
          class_name: 'TrackData',
          inverse_of: :playlist

  validates :name, presence: true
  validates :spotify_id, presence: { message: I18n.t('active_record_validations.spotify_id.presence') },
                         uniqueness: { message: I18n.t('active_record_validations.spotify_id.uniqueness') }

  def to_rspotify_playlist
    spotify_client.get_playlist_by_id(spotify_id)
  end

  def update_track_data!(track_data: nil, offset: 0, self_queuing: nil)
    UpdatePlaylistTrackDataService.call(self, track_data:, offset:, self_queuing:)
  end

  def sync_with_spotify!(rspotify_playlist)
    assign_attributes(song_count: rspotify_playlist.total, name: rspotify_playlist.name)
    save! if changed?
  end
end
