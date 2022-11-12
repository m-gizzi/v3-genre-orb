# frozen_string_literal: true

class CreateTrackData < ActiveRecord::Migration[7.0]
  def change
    create_table :track_data do |t|
      t.references :playlist, null: false, polymorphic: true
      t.timestamps
    end
  end
end
