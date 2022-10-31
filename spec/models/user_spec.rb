# frozen_string_literal: true

require 'rails_helper'

describe User, type: :model do
  subject(:user) { create(:user) }

  describe '#to_rspotify_user' do
    context 'when the user has stored Spotify credentials' do
      before do
        create(:oauth_credential, user:)
      end

      it 'returns an RSpotify::User' do
        expect(user.to_rspotify_user).to be_a RSpotify::User
      end
    end

    context 'when the user does not have saved Spotify credentials' do
      it 'raises an error' do
        expect { user.to_rspotify_user }.to raise_error User::UnauthorizedError
      end
    end
  end
end
