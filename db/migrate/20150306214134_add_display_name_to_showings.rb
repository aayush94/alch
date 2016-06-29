class AddDisplayNameToShowings < ActiveRecord::Migration
  def change
    add_column :showings, :display_name, :string
  end
end
