# frozen_string_literal: true

class RuleGroup < ApplicationRecord
  belongs_to :smart_playlist

  validates :smart_playlist_id, uniqueness: true
end
