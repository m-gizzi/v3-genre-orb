# frozen_string_literal: true

class Track < ApplicationRecord
  has_and_belongs_to_many :artists
  has_and_belongs_to_many :track_data, class_name: 'TrackData'

  validates :name, presence: true
  validates :spotify_id, presence: { message: "ID can't be blank" }, uniqueness: { message: 'ID has already been taken' }
end
