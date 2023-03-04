# frozen_string_literal: true

FactoryBot.define do
  factory :track_data_import do
    scraping_status { 'completed' }
    playlist { create(:playlist, spotify_id: generate_spotify_id) }

    trait :current_track_data do
      after(:create) do |track_data_import|
        track_data_import.playlist.current_track_data = track_data_import
      end
    end
  end
end
