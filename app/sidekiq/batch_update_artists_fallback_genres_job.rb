# frozen_string_literal: true

class BatchUpdateArtistsFallbackGenresJob
  include Sidekiq::Job

  def perform
    args = Artist.with_no_genres.pluck(:id).zip
    UpdateArtistFallbackGenresJob.perform_bulk(args)
  end
end
