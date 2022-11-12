# frozen_string_literal: true

class Genre < ApplicationRecord
  has_many :artists_genres, dependent: :destroy
  has_many :artists, through: :artists_genres

  validates :name, presence: true, uniqueness: true
end
