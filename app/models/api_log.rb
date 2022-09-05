# frozen_string_literal: true

class ApiLog < ApplicationRecord
  belongs_to :user

  validates :request_url, presence: true
  validates :response_status, presence: true
end
