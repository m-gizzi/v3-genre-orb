# frozen_string_literal: true

class OauthCredential < ApplicationRecord
  belongs_to :user

  validates :access_token, :refresh_token, presence: true
  validates :user_id, uniqueness: true

  def update_tokens!(access_token:, refresh_token:)
    update!(
      access_token: encrypt_for_writing(access_token),
      refresh_token: encrypt_for_writing(refresh_token)
    )
  end

  def decrypted_access_token
    decrypt_for_reading(access_token)
  end

  def decrypted_refresh_token
    decrypt_for_reading(refresh_token)
  end

  private

  def message_encryptor
    ActiveSupport::MessageEncryptor.new(ENV.fetch('OAUTH_ENCRYPTION_SECRET'))
  end

  def encrypt_for_writing(token)
    message_encryptor.encrypt_and_sign(token)
  end

  def decrypt_for_reading(token)
    message_encryptor.decrypt_and_verify(token)
  end
end
