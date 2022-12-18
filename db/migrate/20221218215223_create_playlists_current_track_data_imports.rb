# frozen_string_literal: true

class CreatePlaylistsCurrentTrackDataImports < ActiveRecord::Migration[7.0]
  def change
    create_table :playlists_current_track_data_imports do |t|
      t.references :playlist, null: false, polymorphic: true, index: { unique: true }
      t.references :track_data_import, null: false, foreign_key: true, index: {
        name: 'index_playlists_current_track_data_on_track_data_import_id'
      }
      t.timestamps
    end
  end
end
