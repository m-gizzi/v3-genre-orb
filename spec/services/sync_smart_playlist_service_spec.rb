# frozen_string_literal: true

require 'rails_helper'

describe SyncSmartPlaylistService do
  subject(:service) { described_class.new(smart_playlist) }

  let(:smart_playlist) { create(:smart_playlist) }

  describe '#call' do
    it 'returns false if the playlist has no track_data' do
      expect(service.call).to be false
    end

    context 'when the playlist has track_data' do
      let(:playlist_current_tracks) { Track.all.sample(25) }
      let(:import) { create(:track_data_import, :current_track_data, playlist: smart_playlist.playlist) }

      before do
        create_list(:track, 150)
        import.tracks << playlist_current_tracks

        allow(FilterTracksByRuleGroupService).to receive(:call).and_return(goal_track_ids)
      end

      context 'when there are tracks to add to the playlist' do
        let(:goal_track_ids) { Track.ids }

        it 'enqueues the right number of AddTracksToPlaylistJob jobs' do
          expect { service.call }.to change(AddTracksToPlaylistJob.jobs, :size).by(2)
        end
      end

      context 'when there are no tracks to add to the playlist' do
        let(:goal_track_ids) { playlist_current_tracks.pluck(:id) }

        it 'does not enqueue any AddTracksToPlaylistJob jobs' do
          expect { service.call }.not_to change(AddTracksToPlaylistJob.jobs, :size)
        end
      end

      context 'when there are tracks to remove from the playlist' do
        let(:goal_track_ids) { [] }

        it 'enqueues the right number of RemoveTracksFromPlaylistJob jobs' do
          expect { service.call }.to change(RemoveTracksFromPlaylistJob.jobs, :size).by(1)
        end
      end

      context 'when there are no tracks to remove from the playlist' do
        let(:goal_track_ids) { playlist_current_tracks.pluck(:id) }

        it 'does not enqueue any RemoveTracksFromPlaylistJob jobs' do
          expect { service.call }.not_to change(RemoveTracksFromPlaylistJob.jobs, :size)
        end
      end
    end
  end
end
