# frozen_string_literal: true

require 'rails_helper'

describe DeleteOldTrackDataImportsJob, type: :job do
  let!(:old_track_data_import) { create(:track_data_import, created_at: 181.days.ago, playlist:) }
  let!(:new_track_data_import) { create(:track_data_import, created_at: 179.days.ago, playlist:) }
  let(:playlist) { create(:playlist) }

  describe '#perform' do
    it 'deletes TrackDataImports older than 180 days' do
      expect { described_class.perform_async }.to change { TrackDataImport.exists?(old_track_data_import.id) }.to(false)
    end

    it 'does not delete TrackDataImports that are newer than 180 days' do
      expect { described_class.perform_async }.not_to(change { TrackDataImport.exists?(new_track_data_import.id) })
    end

    context 'when the TrackDataImport to be deleted is current_track_data for a Playlist' do
      before do
        playlist.current_track_data = old_track_data_import
      end

      it 'does not delete TrackDataImports that are current_track_data for a Playlist' do
        expect { described_class.perform_async }.not_to(change { TrackDataImport.exists?(old_track_data_import.id) })
      end
    end
  end
end
