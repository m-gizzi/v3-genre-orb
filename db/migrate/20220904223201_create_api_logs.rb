# frozen_string_literal: true

class CreateApiLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :api_logs do |t|
      t.string :request_url, null: false
      t.json :request_headers
      t.json :request_params
      t.json :request_body
      t.integer :response_status, null: false
      t.json :response_headers
      t.json :response_body
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
