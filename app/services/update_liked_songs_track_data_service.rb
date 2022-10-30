# frozen_string_literal: true

class UpdateLikedSongsTrackDataService < UpdatePlaylistTrackDataService
  def call
    rspotify_user = playlist.user.to_rspotify_user
    response = spotify_client.get_liked_tracks(rspotify_user, offset:)
    playlist.sync_with_spotify!(response)

    process_response(response)

    if response.next_url.present?
      offset = response.calculate_next_offset
      case self_queuing
      when 'asynchronous'
        UpdateLikedSongsTrackDataJob.perform_async(playlist.id, self_queuing, track_data.id, offset)
      when 'synchronous'
        playlist.update_track_data!(track_data:, offset:, self_queuing:)
      end
    else
      track_data.completed!
    end
  end

  private

  def log_service_progress(response)
    Rails.logger.info(
      {
        playlist_name: 'Liked Tracks',
        user_name: playlist.user.full_name,
        offset: response.offset
      }
    )
  end
end
