# frozen_string_literal: true

FactoryBot.define do
  factory :liked_songs_playlist do
    association :user, :with_spotify_tokens,
                decrypted_access_token: ENV.fetch('DEVELOPER_SPOTIFY_ACCESS_TOKEN'),
                decrypted_refresh_token: ENV.fetch('DEVELOPER_SPOTIFY_REFRESH_TOKEN')
  end
end
