# frozen_string_literal: true

require 'rails_helper'

describe FilterTracksByRuleGroupService do
  subject(:service) { described_class.new(Track.all, rule_group) }

  let(:rule_group) { create(:rule_group) }
  let!(:track_that_passes_any_artist_genre_rules) { create(:track, artists: [artist1]) }
  let!(:track_that_passes_all_artist_genre_rules) { create(:track, artists: [artist2, artist3]) }
  let!(:track_that_only_passes_one_rule1) { create(:track, artists: [artist4]) }
  let!(:track_that_only_passes_one_rule2) { create(:track, artists: [artist5]) }

  let(:artist1) { create(:artist, genres: [genre_a, genre_b]) }
  let(:artist2) { create(:artist, genres: [genre_c, genre_d]) }
  let(:artist3) { create(:artist, genres: [genre_c, genre_d]) }
  let(:artist4) { create(:artist, genres: [genre_b]) }
  let(:artist5) { create(:artist, genres: [genre_d]) }
  let(:genre_a) { create(:genre, name: 'Genre A') }
  let(:genre_b) { create(:genre, name: 'Genre B') }
  let(:genre_c) { create(:genre, name: 'Genre C') }
  let(:genre_d) { create(:genre, name: 'Genre D') }

  before do
    create(:rule, condition: 'any_artists_genre', value: 'Genre A', rule_group:)
    create(:rule, condition: 'any_artists_genre', value: 'Genre B', rule_group:)
    create(:rule, condition: 'all_artists_genre', value: 'Genre C', rule_group:)
    create(:rule, condition: 'all_artists_genre', value: 'Genre D', rule_group:)
  end

  describe '#call' do
    it 'returns any track ids that pass any any_artists_genre rules' do
      expect(service.call).to include track_that_passes_any_artist_genre_rules.id
    end

    it 'returns any track ids that pass any all_artists_genre rule' do
      expect(service.call).to include track_that_passes_all_artist_genre_rules.id
    end

    it 'returns any track ids that pass at least one rule, regardless of whether they fail any others' do
      expect(service.call).to include track_that_only_passes_one_rule1.id, track_that_only_passes_one_rule2.id
    end

    it 'returns an ActiveRecord::Collection' do
      expect(service.call).to all(be_a(Integer))
    end
  end
end
