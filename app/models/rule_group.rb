# frozen_string_literal: true

class RuleGroup < ApplicationRecord
  belongs_to :smart_playlist
  has_many :rules, dependent: :destroy

  validates :smart_playlist_id, uniqueness: true

  enum criterion: {
    any_pass: 'any_pass'
  }
end
