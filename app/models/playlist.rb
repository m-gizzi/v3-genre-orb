# frozen_string_literal: true

class Playlist < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :playlist_id, presence: { message: "ID can't be blank" }, uniqueness: { message: 'ID has already been taken' }
end
