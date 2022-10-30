# frozen_string_literal: true

FactoryBot.define do
  factory :oauth_credential do
    user

    transient do
      decrypted_access_token { 'Test Access Token' }
      decrypted_refresh_token { 'Test Refresh Token' }
    end

    after(:build) do |oauth_credential, evaluator|
      oauth_credential.update_tokens!(access_token: evaluator.decrypted_access_token,
                                      refresh_token: evaluator.decrypted_refresh_token)
    end
  end
end
