# frozen_string_literal: true

class DeleteOldTrackDataImportsJob
  include Sidekiq::Job

  # Finds all TrackDataImports that are older than 7 days
  # and are not a current_track_data for anything and destroys them
  def perform
    TrackDataImport.left_outer_joins(:playlists_current_track_data_import)
                   .where(
                     created_at: ..7.days.ago,
                     playlists_current_track_data_imports: { playlist_id: nil }
                   ).destroy_all
  end
end
