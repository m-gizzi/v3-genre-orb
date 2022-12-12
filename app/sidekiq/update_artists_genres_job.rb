# frozen_string_literal: true

class UpdateArtistsGenresJob
  include Sidekiq::Job
  sidekiq_options queue: :spotify_api_calls

  def perform(artist_ids)
    artists = Artist.where(id: artist_ids)
    artists.sync_genres!
  end
end
