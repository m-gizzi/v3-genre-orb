# frozen_string_literal: true

FactoryBot.define do
  factory :track do
    name { 'Captain Marvel' }
    spotify_id { generate_spotify_id }
  end
end
