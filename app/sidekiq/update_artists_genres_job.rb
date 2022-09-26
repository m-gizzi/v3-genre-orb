# frozen_string_literal: true

class UpdateArtistsGenresJob
  include Sidekiq::Job

  def perform(artist_ids)
    artists = Artist.where(id: artist_ids)
    return if artists.empty?

    UpdateArtistsGenresService.call(artists)
  rescue ArgumentError
    # This exception cannot be retried
  end
end
