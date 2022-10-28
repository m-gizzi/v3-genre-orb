# frozen_string_literal: true

class AddPlaylistTypeToTrackData < ActiveRecord::Migration[7.0]
  def change
    add_column :track_data, :playlist_type, :string, null: false, default: 'Playlist'
  end
end
