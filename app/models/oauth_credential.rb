# frozen_string_literal: true

class OauthCredential < ApplicationRecord
  belongs_to :user

  validates :access_token, :refresh_token, presence: true
end
