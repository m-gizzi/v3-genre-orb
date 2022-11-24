# frozen_string_literal: true

class CreateSmartPlaylists < ActiveRecord::Migration[7.0]
  def change
    create_table :smart_playlists do |t|
      t.references :playlist, null: false, foreign_key: true
      t.integer :track_limit, default: 10_000, null: false
      t.timestamps
    end
  end
end
