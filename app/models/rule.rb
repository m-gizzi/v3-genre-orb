# frozen_string_literal: true

class Rule < ApplicationRecord
  belongs_to :rule_group

  enum condition: {
    genre: 'genre'
  }
end
