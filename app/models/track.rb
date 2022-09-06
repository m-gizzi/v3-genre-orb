# frozen_string_literal: true

class Track < ApplicationRecord
  validates :name, presence: true
  validates :spotify_id, presence: { message: "ID can't be blank" }, uniqueness: { message: 'ID has already been taken' }
end
