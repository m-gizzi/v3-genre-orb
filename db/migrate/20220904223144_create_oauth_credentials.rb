# frozen_string_literal: true

class CreateOauthCredentials < ActiveRecord::Migration[7.0]
  def change
    create_table :oauth_credentials do |t|
      t.string     :access_token, null: false
      t.string     :refresh_token, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
