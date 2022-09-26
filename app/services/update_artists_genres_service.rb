# frozen_string_literal: true

require 'exceptions'

class UpdateArtistsGenresService < ApplicationService
  attr_reader :artists

  def initialize(artists)
    if artists.count > 50
      raise InvalidJobError,
            "#{self.class} cannot accept more than 50 artists as arguments, please use a batch job instead"
    end

    @artists = artists
  end

  def call
    spotify_ids = artists.pluck(:spotify_id)
    response = RSpotify::Artist.find(spotify_ids)
    response.each do |rspotify_artist|
      artist = Artist.find_by(spotify_id: rspotify_artist.id)
      genres = rspotify_artist.genres.map do |genre_name|
        Genre.find_or_create_by!(name: genre_name)
      end
      artist.genres = genres
    end
  end
end
