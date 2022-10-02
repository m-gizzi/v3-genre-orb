# frozen_string_literal: true

require 'rails_helper'

describe UpdateArtistsGenresJob, type: :job do
  let(:artist_id) { create(:artist).id }

  describe '#perform', :vcr do
    it 'creates new Genres from the response' do
      expect { described_class.perform_async(artist_id) }.to change(Genre, :count)
    end
  end
end
