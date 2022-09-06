# frozen_string_literal: true

class TrackData < ApplicationRecord
  belongs_to :playlist
  has_and_belongs_to_many :tracks
end
