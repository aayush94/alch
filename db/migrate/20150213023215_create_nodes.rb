class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :title
      t.text :body
      t.boolean :is_start
      t.boolean :is_goal
      t.boolean :is_failure
      t.boolean :requires_justification

      t.timestamps null: false
    end
  end
end
