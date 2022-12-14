# frozen_string_literal: true

require 'has_spotify_client'

class FetchArtistFallbackGenresService < ApplicationService
  include HasSpotifyClient

  attr_reader :artist

  def initialize(artist)
    @artist = artist
  end

  def call
    fallback_genres = determine_fallback_genres

    fallback_genres.map do |genre_name|
      Genre.find_or_initialize_by(name: genre_name)
    end
  end

  private

  def determine_fallback_genres
    rspotify_artist = artist.to_rspotify_artist
    spotify_client.get_related_artists(rspotify_artist).flat_map(&:genres).uniq
  end
end
