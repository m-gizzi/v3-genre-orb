# frozen_string_literal: true

require 'rails_helper'

describe Rule, type: :model do
  describe '#tracks_that_pass_condition' do
    include_context 'with Tracks with Artists and Genres'

    let(:rule1) { create(:rule, value: genre_name_matches_some_artists, condition:) }
    let(:rule2) { create(:rule, value: genre_name_matches_all_artists, condition:) }
    let(:user1) { rule1.user }
    let(:user2) { rule2.user }
    let(:tracks) { [track_with_genres, nil_genre_track] }

    before do
      allow(user1).to receive(:current_tracks).and_return(Track.where(id: tracks))
      allow(user2).to receive(:current_tracks).and_return(Track.where(id: tracks))
    end

    context 'when the Rule condition is :any_artists_genre' do
      let(:condition) { 'any_artists_genre' }

      it 'returns Tracks that have at least one Artist in the specified genre' do
        expect(rule1.tracks_that_pass_condition).to contain_exactly(track_with_genres)
      end

      it 'returns Tracks that have all Artists in the specified genre' do
        expect(rule2.tracks_that_pass_condition).to contain_exactly(track_with_genres)
      end
    end

    context 'when the Rule condition is :all_artists_genre' do
      let(:condition) { 'all_artists_genre' }

      it 'returns Tracks that have at least one Artist in the specified genre' do
        expect(rule1.tracks_that_pass_condition).to be_empty
      end

      it 'returns Tracks that have all Artists in the specified genre' do
        expect(rule2.tracks_that_pass_condition).to contain_exactly(track_with_genres)
      end
    end
  end
end
