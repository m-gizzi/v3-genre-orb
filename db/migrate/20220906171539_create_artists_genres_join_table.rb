# frozen_string_literal: true

class CreateArtistsGenresJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :artists, :genres do |t|
      t.index :artist_id
      t.index :genre_id
    end
    add_foreign_key :artists_genres, :artists
    add_foreign_key :artists_genres, :genres
  end
end
