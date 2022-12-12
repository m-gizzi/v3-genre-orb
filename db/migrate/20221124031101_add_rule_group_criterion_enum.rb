# frozen_string_literal: true

class AddRuleGroupCriterionEnum < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL.squish
      CREATE TYPE rule_group_criterion AS ENUM ('any_pass');
    SQL

    add_column :rule_groups, :criterion, :rule_group_criterion, null: false, default: :any_pass
  end

  def down
    remove_column :rule_groups, :criterion

    execute <<-SQL.squish
      DROP TYPE rule_group_criterion
    SQL
  end
end
