# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    full_name { 'Genre Orb Developer' }
    spotify_id { '31upmxyqdkt5utuji6r5wsrkgn4e' }

    trait :with_spotify_tokens do
      transient do
        decrypted_access_token { 'Test Access Token' }
        decrypted_refresh_token { 'Test Refresh Token' }
      end

      after(:create) do |user, evaluator|
        create(:oauth_credential,
               user:,
               decrypted_access_token: evaluator.decrypted_access_token,
               decrypted_refresh_token: evaluator.decrypted_refresh_token)
      end
    end
  end
end
