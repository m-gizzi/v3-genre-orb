# frozen_string_literal: true

class User < ApplicationRecord
  has_one :oauth_credential, dependent: :destroy

  validates :full_name, presence: true
  validates :spotify_id, presence: true
end
