class AddDefaultValueForHidden < ActiveRecord::Migration
  def change
    change_column :showings, :hidden, :boolean, :default => false
  end
end
