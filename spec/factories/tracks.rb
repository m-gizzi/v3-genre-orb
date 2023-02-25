# frozen_string_literal: true

FactoryBot.define do
  factory :track do
    sequence(:name) { |n| "Test Track #{n}" }
    spotify_id { generate_spotify_id }
  end
end
