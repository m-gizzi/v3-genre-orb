# frozen_string_literal: true

class TrackDataImport < ApplicationRecord
  belongs_to :playlist, polymorphic: true
  has_and_belongs_to_many :tracks

  enum scraping_status: {
    incomplete: 'incomplete',
    completed: 'completed'
  }
end
