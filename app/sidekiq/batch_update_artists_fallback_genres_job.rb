# frozen_string_literal: true

class BatchUpdateArtistsFallbackGenresJob
  include Sidekiq::Job

  def perform
    args = Artist.in_genre(nil).ids.zip
    UpdateArtistFallbackGenresJob.perform_bulk(args)
  end
end
