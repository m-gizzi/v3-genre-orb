# frozen_string_literal: true

class AddNullAndUniqueConstraintToTrackUri < ActiveRecord::Migration[7.0]
  def change
    change_column_null :tracks, :uri, false
    add_index :tracks, :uri, unique: true
  end
end
