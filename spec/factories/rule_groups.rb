# frozen_string_literal: true

FactoryBot.define do
  factory :rule_group do
    criterion { 'any_pass' }

    after(:build) do |rule_group|
      rule_group.smart_playlist ||= build(:smart_playlist)
    end
  end
end
