# frozen_string_literal: true

require 'spotify_client'

class UpdateArtistsGenresService < ApplicationService
  attr_reader :artists

  def initialize(artists)
    @artists = artists
  end

  def call
    rspotify_artists = artists.to_rspotify_artists

    rspotify_artists.each do |rspotify_artist|
      artist = artists.find_by(spotify_id: rspotify_artist.id)

      artist.assign_attributes(name: rspotify_artist.name)
      artist.save! if artist.changed?

      genres = rspotify_artist.genres.map do |genre_name|
        Genre.find_or_create_by!(name: genre_name)
      end
      artist.genres = genres
    end
  end
end
