# frozen_string_literal: true

FactoryBot.define do
  factory :track_data_import do
    scraping_status { 'completed' }
    playlist { create(:playlist, spotify_id: generate_spotify_id) }
  end
end
