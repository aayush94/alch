class AddHiddenToShowings < ActiveRecord::Migration
  def change
    add_column :showings, :hidden, :boolean
  end
end
