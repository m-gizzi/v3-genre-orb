# frozen_string_literal: true

class CreateScrapingStatusEnum < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL.squish
      CREATE TYPE scraping_status AS ENUM ('in_progress', 'completed');
    SQL

    add_column :track_data, :scraping_status, :scraping_status, null: false, default: :in_progress
  end

  def down
    remove_column :track_data, :scraping_status

    execute <<-SQL.squish
      DROP TYPE scraping_status
    SQL
  end
end
