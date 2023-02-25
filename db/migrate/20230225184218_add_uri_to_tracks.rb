# frozen_string_literal: true

class AddUriToTracks < ActiveRecord::Migration[7.0]
  def change
    add_column :tracks, :uri, :string
  end
end
