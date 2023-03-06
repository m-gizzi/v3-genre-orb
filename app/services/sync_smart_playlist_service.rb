# frozen_string_literal: true

class SyncSmartPlaylistService < ApplicationService
  attr_reader :smart_playlist, :playlist

  def initialize(smart_playlist)
    @smart_playlist = smart_playlist
    @playlist = smart_playlist.playlist
  end

  def call
    return false unless playlist.has_scraped_track_data?

    AddTracksToPlaylistJob.perform_bulk(add_tracks_args) if tracks_to_add_to_playlist.present?
    RemoveTracksFromPlaylistJob.perform_bulk(remove_tracks_args) if tracks_to_remove_from_playlist.present?
  end

  private

  def tracks_to_sync_with
    playlist.user.current_tracks
  end

  def target_track_ids
    @target_track_ids ||=
      FilterTracksByRuleGroupService.call(tracks_to_sync_with, smart_playlist.rule_group)
                                    .sample(smart_playlist.track_limit)
  end

  def current_track_ids
    @current_track_ids ||= playlist.current_track_data.tracks.ids
  end

  def tracks_to_add_to_playlist
    target_track_ids - current_track_ids
  end

  def tracks_to_remove_from_playlist
    current_track_ids - target_track_ids
  end

  def add_tracks_args
    tracks_to_add_to_playlist.each_slice(SpotifyClient::MAXIMUM_TRACKS_ADDED_PER_CALL).map do |track_ids|
      [playlist.id, track_ids]
    end
  end

  def remove_tracks_args
    tracks_to_remove_from_playlist.each_slice(SpotifyClient::MAXIMUM_TRACKS_REMOVED_PER_CALL).map do |track_ids|
      [playlist.id, track_ids]
    end
  end
end
