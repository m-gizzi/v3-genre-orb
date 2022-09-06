# frozen_string_literal: true

class CreatePlaylists < ActiveRecord::Migration[7.0]
  def change
    create_table :playlists do |t|
      t.string :name, null: false, index: true
      t.string :spotify_id, null: false
      t.integer :song_count
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
