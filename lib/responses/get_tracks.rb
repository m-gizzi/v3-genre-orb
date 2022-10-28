# frozen_string_literal: true

module Responses
  class GetTracks
    attr_reader :items, :limit, :offset, :next_url

    def initialize(response)
      @items = response['items']
      @limit = response['limit']
      @offset = response['offset']
      @next_url = response['next']
    end

    def calculate_next_offset
      limit + offset
    end
  end
end
