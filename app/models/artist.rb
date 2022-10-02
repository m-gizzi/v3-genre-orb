# frozen_string_literal: true

require 'spotify_client'

class Artist < ApplicationRecord
  has_and_belongs_to_many :tracks
  has_many :artists_genres, dependent: :destroy
  has_many :genres, through: :artists_genres

  scope :with_no_genres, -> { left_joins(:genres).where(genres: nil) }

  validates :name, presence: true
  validates :spotify_id, presence: { message: I18n.t('active_record_validations.spotify_id.presence') },
                         uniqueness: { message: I18n.t('active_record_validations.spotify_id.uniqueness') }

  def to_rspotify_artist
    SpotifyClient.get_artists_by_ids([spotify_id]).first
  end

  def self.to_rspotify_artists
    find_in_batches(batch_size: SpotifyClient::MAXIMUM_ARTIST_LOOKUPS_PER_CALL).with_object([]) do |artists, array|
      spotify_ids = artists.pluck(:spotify_id)
      rspotify_artists = SpotifyClient.get_artists_by_ids(spotify_ids)
      array.push(*rspotify_artists)
    end
  end

  def self.update_genres!
    UpdateArtistsGenresService.call(self)
  end

  def sync_with_spotify!(rspotify_artist)
    assign_attributes(name: rspotify_artist.name)
    save! if changed?
  end
end
