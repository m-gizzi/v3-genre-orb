# frozen_string_literal: true

FactoryBot.define do
  factory :artist do
    name { "Howlin' Wolf" }
    spotify_id { generate_spotify_id }
  end
end
