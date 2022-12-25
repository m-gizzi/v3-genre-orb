# frozen_string_literal: true

class PlaylistsCurrentTrackDataImport < ApplicationRecord
  belongs_to :playlist, polymorphic: true
  belongs_to :track_data_import

  validates :playlist_id, uniqueness: { scope: :playlist_type }
  validate :track_data_import_is_complete
  validate :track_data_import_belongs_to_playlist

  def track_data_import_is_complete
    errors.add(:track_data_import_scraping_status, 'must_be_completed') unless track_data_import.completed?
  end

  def track_data_import_belongs_to_playlist
    errors.add(:track_data_import, 'must_belong_to_playlist') unless track_data_import.playlist == playlist
  end
end
