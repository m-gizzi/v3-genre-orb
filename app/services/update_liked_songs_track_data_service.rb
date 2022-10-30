# frozen_string_literal: true

class UpdateLikedSongsTrackDataService < UpdatePlaylistTrackDataService
  private

  def rspotify_object
    playlist.user.to_rspotify_user
  end

  def object_to_be_synced_with
    response
  end

  def make_api_call
    spotify_client.get_liked_tracks(rspotify_object, offset:)
  end

  def log_service_progress(response)
    Rails.logger.info(
      {
        playlist_name: 'Liked Tracks',
        user_name: playlist.user.spotify_id,
        offset: response.offset
      }
    )
  end
end
