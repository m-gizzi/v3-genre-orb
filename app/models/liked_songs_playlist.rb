# frozen_string_literal: true

class LikedSongsPlaylist < ApplicationRecord
  belongs_to :user
  has_many :track_data, dependent: :destroy, class_name: 'TrackData', as: :playlist
  has_one :current_track_data,
          -> { where(scraping_status: 'completed').order(created_at: :desc) },
          class_name: 'TrackData',
          inverse_of: :playlist,
          as: :playlist

  def update_track_data!
    UpdateLikedSongsTrackDataService.call(self)
  end

  def sync_with_spotify!(spotify_response)
    assign_attributes(song_count: spotify_response.total)
    save! if changed?
  end
end
