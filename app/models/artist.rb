# frozen_string_literal: true

require 'has_spotify_client'

class Artist < ApplicationRecord
  include HasSpotifyClient

  has_and_belongs_to_many :tracks
  has_many :artists_genres, dependent: :destroy
  has_many :genres, through: :artists_genres
  has_many :artists_fallback_genres,
           -> { where(fallback_genre: true) },
           class_name: 'ArtistsGenre',
           dependent: :destroy,
           inverse_of: :artist

  has_many :fallback_genres, through: :artists_fallback_genres, source: :genre

  scope :matching_any_genres, ->(genres) { left_joins(:genres).where(genres: { name: genres }).distinct }
  scope :not_matching_any_genres, ->(genres) { where.not(id: matching_any_genres(genres)) }

  validates :name, presence: true
  validates :spotify_id, presence: { message: I18n.t('active_record_validations.spotify_id.presence') },
                         uniqueness: { message: I18n.t('active_record_validations.spotify_id.uniqueness') }

  class << self
    alias in_genre matching_any_genres
    alias not_in_genre not_matching_any_genres
  end

  def self.matching_all_genres(genres)
    unless genres.is_a?(Array)
      raise 'Use logically equivalent .matching_any_genres if only passing a single string as an argument.'
    end

    first_query = matching_any_genres(genres.shift).ids
    ids = genres.reduce(first_query) { |queries, genre| queries & matching_any_genres(genre).ids }
    where(id: ids)
  end

  def self.not_matching_all_genres(genres)
    unless genres.is_a?(Array)
      raise 'Use logically equivalent .not_matching_any_genres if only passing a single string as an argument.'
    end

    where.not(id: matching_all_genres(genres))
  end

  def to_rspotify_artist
    spotify_client.get_artists_by_ids([spotify_id]).first
  end

  def self.to_rspotify_artists
    find_in_batches(batch_size: SpotifyClient::MAXIMUM_ARTIST_LOOKUPS_PER_CALL).with_object([]) do |artists, array|
      spotify_ids = artists.pluck(:spotify_id)
      rspotify_artists = spotify_client.get_artists_by_ids(spotify_ids)
      array.push(*rspotify_artists)
    end
  end

  def self.sync_genres!
    UpdateArtistsGenresService.call(self)
  end

  def fallback_genres_from_spotify
    @fallback_genres_from_spotify ||= FetchArtistFallbackGenresService.call(self)
  end

  def sync_fallback_genres!
    return false unless can_sync_fallback_genres?

    new_genres = fallback_genres_from_spotify - fallback_genres
    old_genres = fallback_genres - fallback_genres_from_spotify

    fallback_genres << new_genres
    fallback_genres.destroy(old_genres)
  end

  def sync_with_spotify!(rspotify_artist)
    assign_attributes(name: rspotify_artist.name)
    save! if changed?
  end

  private

  def can_sync_fallback_genres?
    artists_genres.where(fallback_genre: false).empty?
  end
end
