# frozen_string_literal: true

RSpotify.authenticate(ENV.fetch('SPOTIFY_CLIENT_ID', nil), ENV.fetch('SPOTIFY_CLIENT_SECRET', nil))
