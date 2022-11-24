# frozen_string_literal: true

class CreateTrackDataTracksJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_table :track_data_tracks do |t|
      t.references :track_data, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: true
    end
    add_index :track_data_tracks, %i[track_data_id track_id], unique: true
  end
end
