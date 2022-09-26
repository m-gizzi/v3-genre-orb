# frozen_string_literal: true

class UpdateArtistsGenresJob
  include Sidekiq::Job

  def perform(artist_ids)
    artists = Artist.where(id: artist_ids)
    return if artists.empty?

    UpdateArtistsGenresService.call(artists)
  rescue InvalidJobError
    # This exception is raised when the job is queued with bad arguments, it will never be retried successfully
  end
end
