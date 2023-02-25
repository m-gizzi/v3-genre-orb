# frozen_string_literal: true

FactoryBot.define do
  factory :playlist do
    spotify_id { generate_spotify_id }
    name { 'Genre Orb Test Playlist' }
    user
  end
end
