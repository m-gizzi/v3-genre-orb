# frozen_string_literal: true

class AddUniqueCompositeIndexToArtistsGenres < ActiveRecord::Migration[7.0]
  def change
    add_index :artists_genres, %i[artist_id genre_id], unique: true, name: 'index_by_artist_and_genre'
  end
end
