# frozen_string_literal: true

require 'rails_helper'

describe OauthCredential, type: :model do
  subject(:oauth_credential) { create(:oauth_credential) }

  let(:access_token) { 'Test Access Token' }
  let(:refresh_token) { 'Test Refresh Token' }

  describe '#update_tokens!' do
    let(:new_tokens) do
      {
        access_token: 'New Access Token',
        refresh_token: 'New Refresh Token'
      }
    end

    it 'updates the credentials' do
      expect do
        oauth_credential.update_tokens!(**new_tokens)
      end.to change(oauth_credential, :decrypted_access_token).from('Test Access Token').to('New Access Token')
         .and(change(oauth_credential, :decrypted_refresh_token).from('Test Refresh Token').to('New Refresh Token'))
    end
  end

  describe '#decrypted_access_token' do
    it 'returns the access token decrypted' do
      expect(oauth_credential.decrypted_access_token).to eq 'Test Access Token'
    end
  end

  describe '#decrypted_refresh_token' do
    it 'returns the refresh token decrypted' do
      expect(oauth_credential.decrypted_refresh_token).to eq 'Test Refresh Token'
    end
  end
end
