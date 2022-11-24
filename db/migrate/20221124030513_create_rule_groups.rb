# frozen_string_literal: true

class CreateRuleGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :rule_groups do |t|
      t.references :smart_playlist, null: false, foreign_key: true
      t.timestamps
    end
  end
end
