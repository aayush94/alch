class AddDefaultValuesToNode < ActiveRecord::Migration
  def up
  	change_column :nodes, :title, :string, :default => ""
  	change_column :nodes, :body, :text
  	change_column :nodes, :is_start, :boolean, :default => false
  	change_column :nodes, :is_goal, :boolean, :default => false
  	change_column :nodes, :is_failure, :boolean, :default => false
  	change_column :nodes, :requires_justification, :boolean, :default => false
  end

  def down
  	change_column :nodes, :title, :string, :default => nil
  	change_column :nodes, :body, :text
  	change_column :nodes, :is_start, :boolean, :default => nil
  	change_column :nodes, :is_goal, :boolean, :default => nil
  	change_column :nodes, :is_failure, :boolean, :default => nil
  	change_column :nodes, :requires_justification, :boolean, :default => nil
  end
end
