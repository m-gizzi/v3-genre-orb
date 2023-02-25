# frozen_string_literal: true

class TrackDataImport < ApplicationRecord
  belongs_to :playlist, polymorphic: true
  has_and_belongs_to_many :tracks
  has_one :playlists_current_track_data_import, dependent: :destroy

  enum scraping_status: {
    incomplete: 'incomplete',
    completed: 'completed'
  }
end
