# frozen_string_literal: true

require 'spotify_client'

module HasSpotifyClient
  extend ActiveSupport::Concern

  def spotify_client
    self.class.spotify_client
  end

  class_methods do
    def spotify_client
      SpotifyClient.new
    end
  end
end
