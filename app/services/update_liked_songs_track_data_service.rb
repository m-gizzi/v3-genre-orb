# frozen_string_literal: true

class UpdateLikedSongsTrackDataService < UpdatePlaylistTrackDataService
  def call
    rspotify_user = playlist.user.to_rspotify_user
    response = spotify_client.get_liked_tracks(rspotify_user)
    playlist.sync_with_spotify!(response)

    process_response(response)

    while response.next_url.present?
      offset = response.calculate_next_offset
      response = spotify_client.get_liked_tracks(rspotify_user, offset:)
      process_response(response)
    end
    track_data.completed!
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
