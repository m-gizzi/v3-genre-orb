# frozen_string_literal: true

class UpdateArtistFallbackGenresJob
  include Sidekiq::Job

  def perform(artist_id)
    artist = Artist.find_by(id: artist_id)
    artist&.sync_fallback_genres!
  end
end
