class CreateChoices < ActiveRecord::Migration
  def change
    create_table :choices do |t|
      t.references :node, index: true
      t.integer :to_node_id
      t.string :text

      t.timestamps null: false
    end
    add_foreign_key :choices, :nodes
  end
end
