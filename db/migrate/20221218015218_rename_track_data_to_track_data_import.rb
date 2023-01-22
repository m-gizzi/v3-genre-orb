# frozen_string_literal: true

class RenameTrackDataToTrackDataImport < ActiveRecord::Migration[7.0]
  def change
    rename_table :track_data, :track_data_imports
    rename_column :track_data_tracks, :track_data_id, :track_data_import_id
    rename_table :track_data_tracks, :track_data_imports_tracks
  end
end
