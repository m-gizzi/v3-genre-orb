# frozen_string_literal: true

class BatchUpdateArtistsGenresJob
  include Sidekiq::Job

  def perform
    args = Artist.ids.each_slice(SpotifyClient::MAXIMUM_ARTIST_LOOKUPS_PER_CALL).map { |slice| [slice] }
    UpdateArtistsGenresJob.perform_bulk(args)
  end
end
