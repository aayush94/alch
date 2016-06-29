class CreateDecisions < ActiveRecord::Migration
  def change
    create_table :decisions do |t|
      t.references :showing_session, index: true
      t.references :from_node, index: true
      t.references :to_node, index: true
      t.integer :result
      t.string :justification

      t.timestamps null: false
    end

    add_foreign_key :decisions, :showing_sessions
    add_foreign_key :decisions, :nodes, column: "from_node_id"
    add_foreign_key :decisions, :nodes, column: "to_node_id"
  end
end
