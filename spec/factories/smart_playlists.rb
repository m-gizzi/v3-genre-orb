# frozen_string_literal: true

FactoryBot.define do
  factory :smart_playlist do
    playlist { create(:playlist, spotify_id: generate_spotify_id) }
  end
end
