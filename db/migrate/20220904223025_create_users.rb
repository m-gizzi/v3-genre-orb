# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :full_name, null: false
      t.string :preferred_name
      t.string :spotify_id, null: false, index: true
      t.timestamps
    end
  end
end
