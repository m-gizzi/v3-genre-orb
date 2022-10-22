# frozen_string_literal: true

class TrackData < ApplicationRecord
  belongs_to :playlist
  has_and_belongs_to_many :tracks

  enum scraping_status: {
    in_progress: 'in_progress',
    completed: 'completed'
  }
end
