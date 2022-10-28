# frozen_string_literal: true

class LikedSongsPlaylist < ApplicationRecord
  belongs_to :user
  has_many :track_data, dependent: :destroy, class_name: 'TrackData', as: :playlist
  has_one :current_track_data,
          -> { where(scraping_status: 'completed').order(created_at: :desc) },
          class_name: 'TrackData',
          inverse_of: :playlist,
          as: :playlist
end
