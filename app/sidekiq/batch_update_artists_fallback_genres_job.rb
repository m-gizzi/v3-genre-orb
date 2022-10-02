# frozen_string_literal: true

class BatchUpdateArtistsFallbackGenresJob
  include Sidekiq::Job

  def perform
    Artist.with_no_genres.find_in_batches do |artists|
      args = artists.pluck(:id).zip
      UpdateArtistFallbackGenresJob.perform_bulk(args)
    end
  end
end
