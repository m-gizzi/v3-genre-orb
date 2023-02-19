# frozen_string_literal: true

RSpec.shared_context 'with Tracks with Artists and Genres' do
  let(:track_with_genres) do
    create(
      :track,
      name: 'Track with Genres',
      spotify_id: generate_spotify_id,
      artists: [
        create(:artist, spotify_id: generate_spotify_id, genres: [genre_a, genre_b]),
        create(:artist, spotify_id: generate_spotify_id, genres: [genre_a])
      ]
    )
  end
  let(:nil_genre_track) do
    create(
      :track,
      name: 'Track with no Genres',
      spotify_id: generate_spotify_id,
      artists: [create(:artist, spotify_id: generate_spotify_id)]
    )
  end
  let(:genre_a) { create(:genre, name: genre_name_matches_all_artists) }
  let(:genre_b) { create(:genre, name: genre_name_matches_some_artists) }
  let(:genre_name_matches_all_artists) { 'A' }
  let(:genre_name_matches_some_artists) { 'B' }
  let(:genre_name_matches_no_artists) { 'C' }
end
