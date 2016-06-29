class AddLockedToScenarios < ActiveRecord::Migration
  def change
    add_column :scenarios, :locked, :boolean
  end
end
