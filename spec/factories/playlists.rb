# frozen_string_literal: true

FactoryBot.define do
  factory :playlist do
    spotify_id { '3IlD894HSWDF8YlkCP25Sq' }
    name { 'Test Playlist' }
    user
  end
end
