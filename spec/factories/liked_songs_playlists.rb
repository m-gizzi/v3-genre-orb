# frozen_string_literal: true

FactoryBot.define do
  factory :liked_songs_playlist do
    association :user, :with_spotify_tokens
  end
end
