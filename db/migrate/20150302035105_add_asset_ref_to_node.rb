class AddAssetRefToNode < ActiveRecord::Migration
  def change
    add_reference :nodes, :asset, index: true
    add_foreign_key :nodes, :assets
  end
end
