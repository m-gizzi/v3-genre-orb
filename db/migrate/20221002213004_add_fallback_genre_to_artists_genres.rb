# frozen_string_literal: true

class AddFallbackGenreToArtistsGenres < ActiveRecord::Migration[7.0]
  def change
    add_column :artists_genres, :fallback_genre, :boolean, null: false, default: false
    add_index :artists_genres, :fallback_genre
  end
end
