# frozen_string_literal: true

class CreateArtistsGenresJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_table :artists_genres do |t|
      t.references :artist, null: false, foreign_key: true
      t.references :genre, null: false, foreign_key: true
      t.boolean :fallback_genre, null: false, default: false

      t.timestamps
    end
    add_index :artists_genres, %i[artist_id genre_id], unique: true, name: 'index_by_artist_and_genre'
  end
end
