# frozen_string_literal: true

module Responses
  class GetTracks
    attr_reader :items, :limit, :offset, :next_url, :total

    def initialize(response)
      @items = response['items']
      @limit = response['limit']
      @offset = response['offset']
      @next_url = response['next']
      @total = response['total']
    end
  end
end
