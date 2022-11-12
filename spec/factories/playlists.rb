# frozen_string_literal: true

FactoryBot.define do
  factory :playlist do
    spotify_id { '3nwz2mVTVbWSGMSFMzN7pu' }
    name { 'Genre Orb Test Playlist' }
    user

    trait :many_tracks do
      spotify_id { '58OHAm8Z4eIHez0Pi3ZFsU' }
      name { 'Long Test Playlist' }
    end
  end
end
