# frozen_string_literal: true

FactoryBot.define do
  factory :artist do
    sequence(:name) { |n| "Test Artist #{n}" }
    spotify_id { generate_spotify_id }
  end
end
