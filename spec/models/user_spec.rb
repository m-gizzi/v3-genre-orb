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

  describe '#current_tracks' do
    subject(:method_call) { user.current_tracks }

    let(:playlist) { create(:playlist, user:) }
    let(:liked_songs_playlist) { create(:liked_songs_playlist, user:) }

    before do
      [playlist, liked_songs_playlist].each do |playlist|
        2.times { playlist.track_data_imports.create!(scraping_status: 'completed') }
        playlist.track_data_imports.create!(scraping_status: 'incomplete')
      end

      TrackDataImport.all.each do |track_data|
        track_data.tracks << create(:track, spotify_id: generate_spotify_id)
      end
    end

    it 'returns an ActiveRecord::Relation for chaining additional queries' do
      expect(method_call).to be_a(ActiveRecord::Relation)
    end

    it "returns Tracks from the correct version of the User's TrackData" do
      playlist_track_data = playlist.track_data_imports
                                    .where(scraping_status: 'completed')
                                    .order(created_at: :desc)
                                    .first

      liked_songs_track_data = liked_songs_playlist.track_data_imports
                                                   .where(scraping_status: 'completed')
                                                   .order(created_at: :desc)
                                                   .first

      expect(method_call.flat_map(&:track_data_imports).uniq)
        .to contain_exactly(playlist_track_data, liked_songs_track_data)
    end
  end
end
