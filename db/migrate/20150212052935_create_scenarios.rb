class CreateScenarios < ActiveRecord::Migration
  def change
    create_table :scenarios do |t|
      t.string :name
      t.text :description
      t.integer :root_node_id
      t.boolean :archived

      t.timestamps null: false
    end
    add_index :scenarios, :name, unique: true
  end
end
