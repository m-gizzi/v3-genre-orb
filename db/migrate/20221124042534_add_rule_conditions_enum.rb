# frozen_string_literal: true

class AddRuleConditionsEnum < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL.squish
      CREATE TYPE rule_condition AS ENUM ('genre');
    SQL

    add_column :rules, :condition, :rule_condition, null: false, default: :genre
  end

  def down
    remove_column :rules, :condition

    execute <<-SQL.squish
      DROP TYPE rule_group_criterion
    SQL
  end
end
