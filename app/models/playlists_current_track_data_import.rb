# frozen_string_literal: true

class PlaylistsCurrentTrackDataImport < ApplicationRecord
  belongs_to :playlist, polymorphic: true
  belongs_to :track_data_import

  validates :playlist_id, uniqueness: { scope: :playlist_type }
end
