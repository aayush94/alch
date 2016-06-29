class CreateShowingSessions < ActiveRecord::Migration
  def change
    create_table :showing_sessions do |t|
      t.references :showing, index: true
      t.integer :attempts
      t.references :node, index: true
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :showing_sessions, :showings
    add_foreign_key :showing_sessions, :nodes
    add_foreign_key :showing_sessions, :users
  end
end
