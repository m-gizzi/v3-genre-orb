# frozen_string_literal: true

class CreateTracksArtistsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :tracks, :artists do |t|
      t.index :track_id
      t.index :artist_id
    end
    add_foreign_key :artists_tracks, :artists
    add_foreign_key :artists_tracks, :tracks
    add_index :artists_tracks, %i[track_id artist_id], unique: true
  end
end
