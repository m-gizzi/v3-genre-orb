# frozen_string_literal: true

class LikedSongsPlaylist < ApplicationRecord
  belongs_to :user
  has_many :track_data_imports, dependent: :destroy, as: :playlist
  has_one :playlists_current_track_data_import, dependent: :destroy, as: :playlist
  has_one :current_track_data,
          through: :playlists_current_track_data_import,
          inverse_of: :playlist,
          as: :playlist,
          source: :track_data_import

  validates :user_id, uniqueness: true

  def batch_queue_track_data_update!
    UpdatePlaylistTrackDataBatchQueuingService.call(self)
  end

  def update_track_data!(track_data_import, offset: 0)
    UpdatePlaylistTrackDataService.call(self, track_data_import, offset:)
  end

  def sync_with_spotify!(spotify_response)
    assign_attributes(song_count: spotify_response.total)
    save! if changed?
  end
end
