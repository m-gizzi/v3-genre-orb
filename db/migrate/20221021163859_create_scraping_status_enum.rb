# frozen_string_literal: true

class CreateScrapingStatusEnum < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL.squish
      CREATE TYPE scraping_status AS ENUM ('incomplete', 'completed');
    SQL

    add_column :track_data, :scraping_status, :scraping_status, null: false, default: :incomplete
  end

  def down
    remove_column :track_data, :scraping_status

    execute <<-SQL.squish
      DROP TYPE scraping_status
    SQL
  end
end
