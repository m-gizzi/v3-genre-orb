# frozen_string_literal: true

class AddUniqueIndexOnValueToRule < ActiveRecord::Migration[7.0]
  def change
    add_index :rules, %i[value rule_group_id], unique: true
  end
end
