# frozen_string_literal: true

class CreateTracks < ActiveRecord::Migration[7.0]
  def change
    create_table :tracks do |t|
      t.string :name, null: false
      t.string :spotify_id, null: false
      t.timestamps
    end
  end
end
