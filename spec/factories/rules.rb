# frozen_string_literal: true

FactoryBot.define do
  factory :rule do
    rule_group { create(:rule_group) }
    value { 'Test Genre' }
    condition { 'any_artists_genre' }
  end
end
