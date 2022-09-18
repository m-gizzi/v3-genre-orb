# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    full_name { 'Test User' }
    spotify_id { 'matthewgizzi' }
  end
end
