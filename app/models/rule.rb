# frozen_string_literal: true

class Rule < ApplicationRecord
  belongs_to :rule_group

  validates :value, uniqueness: { scope: :rule_group_id }

  enum condition: {
    any_artists_genre: 'any_artists_genre',
    all_artists_genre: 'all_artists_genre'
  }
end
