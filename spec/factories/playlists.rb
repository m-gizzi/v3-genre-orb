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

    trait :with_authorized_user do
      association :user, :with_spotify_tokens,
                  decrypted_access_token: ENV.fetch('DEVELOPER_SPOTIFY_ACCESS_TOKEN'),
                  decrypted_refresh_token: ENV.fetch('DEVELOPER_SPOTIFY_REFRESH_TOKEN')
    end
  end
end
