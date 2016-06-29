class RemoveImageColumnFromNodes < ActiveRecord::Migration
  def change
    remove_attachment :nodes, :image
  end
end
