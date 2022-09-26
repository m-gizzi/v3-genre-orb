# frozen_string_literal: true

require 'spotify_client'

class UpdateArtistsGenresService < ApplicationService
  attr_reader :artists

  def initialize(artists)
    @artists = artists
  end

  def call
    spotify_ids = artists.pluck(:spotify_id)
    response = SpotifyClient.get_artists_by_ids(spotify_ids)
    response.each do |rspotify_artist|
      artist = Artist.find_by(spotify_id: rspotify_artist.id)
      genres = rspotify_artist.genres.map do |genre_name|
        Genre.find_or_create_by!(name: genre_name)
      end
      artist.genres = genres
    end
  end
end
