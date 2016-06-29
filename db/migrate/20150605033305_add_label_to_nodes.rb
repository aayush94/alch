class AddLabelToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :label, :int
  end
end
