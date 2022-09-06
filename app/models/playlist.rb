# frozen_string_literal: true

class Playlist < ApplicationRecord
  belongs_to :user
  has_many :track_data, dependent: :destroy, class_name: 'TrackData'

  validates :name, presence: true
  validates :spotify_id, presence: { message: "ID can't be blank" }, uniqueness: { message: 'ID has already been taken' }
end
