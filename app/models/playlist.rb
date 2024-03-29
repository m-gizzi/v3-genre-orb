# frozen_string_literal: true

require 'has_spotify_client'

class Playlist < ApplicationRecord
  include HasSpotifyClient

  belongs_to :user
  has_many :track_data_imports, dependent: :destroy, as: :playlist
  has_one :playlists_current_track_data_import, dependent: :destroy, as: :playlist
  has_one :current_track_data,
          through: :playlists_current_track_data_import,
          inverse_of: :playlist,
          source: :track_data_import

  has_one :smart_playlist, dependent: :destroy

  validates :name, presence: true
  validates :spotify_id, presence: { message: I18n.t('active_record_validations.spotify_id.presence') },
                         uniqueness: { message: I18n.t('active_record_validations.spotify_id.uniqueness') }

  def to_rspotify_playlist
    spotify_client.get_playlist_by_id(spotify_id)
  end

  def batch_queue_track_data_update!
    UpdatePlaylistTrackDataBatchQueuingService.call(self)
  end

  def update_track_data!(track_data_import, offset: 0)
    UpdatePlaylistTrackDataService.call(self, track_data_import, offset:)
  end

  def sync_with_spotify!(rspotify_playlist)
    assign_attributes(song_count: rspotify_playlist.total, name: rspotify_playlist.name)
    save! if changed?
  end

  def add_tracks!(new_tracks)
    AddTracksToPlaylistService.call(self, new_tracks)
  end

  def remove_tracks!(tracks_to_remove)
    RemoveTracksFromPlaylistService.call(self, tracks_to_remove)
  end

  def has_scraped_track_data?
    current_track_data.present?
  end
end
