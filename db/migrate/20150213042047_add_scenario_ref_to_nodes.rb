class AddScenarioRefToNodes < ActiveRecord::Migration
  def change
    add_reference :nodes, :scenario, index: true
    add_foreign_key :nodes, :scenarios
  end
end
