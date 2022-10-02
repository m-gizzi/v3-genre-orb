# frozen_string_literal: true

class ArtistsGenre < ApplicationRecord
  belongs_to :artist
  belongs_to :genre
end
