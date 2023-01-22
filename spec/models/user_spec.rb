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
    let(:playlist) { create(:playlist, user:, track_data_imports: create_list(:track_data_import, 2)) }
    let(:liked_songs_playlist) do
      create(:liked_songs_playlist, user:, track_data_imports: create_list(:track_data_import, 2))
    end

    let(:current_playlist_track_data) { playlist.track_data_imports.last }
    let(:old_playlist_track_data) { playlist.track_data_imports.first }
    let(:current_liked_songs_track_data) { liked_songs_playlist.track_data_imports.last }
    let(:old_liked_songs_track_data) { liked_songs_playlist.track_data_imports.first }

    let(:track1) { create(:track) }
    let(:track2) { create(:track) }
    let(:track3) { create(:track) }
    let(:track4) { create(:track) }

    before do
      playlist.current_track_data = current_playlist_track_data
      liked_songs_playlist.current_track_data = current_liked_songs_track_data

      track1.track_data_imports = [current_playlist_track_data, current_liked_songs_track_data]
      track2.track_data_imports = [current_playlist_track_data]
      track3.track_data_imports = [current_liked_songs_track_data]
      track4.track_data_imports = [old_playlist_track_data, old_liked_songs_track_data]
    end

    it 'returns an ActiveRecord::Relation for chaining additional queries' do
      expect(user.current_tracks).to be_a(ActiveRecord::Relation)
    end

    it "only returns the Tracks associated with the User's current_track_data" do
      expect(user.current_tracks).to match_array([track1, track2, track3])
    end

    it "returns Tracks from all of the User's current_track_data" do
      expect(user.current_tracks.flat_map(&:track_data_imports).uniq)
        .to contain_exactly(current_playlist_track_data, current_liked_songs_track_data)
    end
  end
end
