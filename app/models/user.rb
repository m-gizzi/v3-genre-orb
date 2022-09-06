# frozen_string_literal: true

class User < ApplicationRecord
  has_one :oauth_credential, dependent: :destroy
  has_many :playlists, dependent: :destroy
  has_many :api_logs, dependent: :destroy

  validates :full_name, presence: true
  validates :spotify_id, presence: { message: "ID can't be blank" }, uniqueness: { message: 'ID has already been taken' }
end
