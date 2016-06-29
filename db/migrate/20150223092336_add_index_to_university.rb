class AddIndexToUniversity < ActiveRecord::Migration
  def change
    add_index :universities, :name, unique: true
  end
end
