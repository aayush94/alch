class AddToNodeToChoices < ActiveRecord::Migration
  def change
    remove_column :choices, :to_node_id
    add_reference :choices, :to_node, index: true
    add_foreign_key :choices, :nodes, column: "to_node_id"
  end
end
