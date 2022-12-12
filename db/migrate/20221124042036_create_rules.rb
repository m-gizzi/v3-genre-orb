# frozen_string_literal: true

class CreateRules < ActiveRecord::Migration[7.0]
  def change
    create_table :rules do |t|
      t.references :rule_group, null: false, foreign_key: true
      t.string :value
      t.timestamps
    end
  end
end
