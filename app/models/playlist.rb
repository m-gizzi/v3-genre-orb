# frozen_string_literal: true

class Playlist < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :playlist_id, presence: true
end
