class AddIsGradedAndMaxAttemptsToShowings < ActiveRecord::Migration
  def change
    add_column :showings, :is_graded, :boolean
    add_column :showings, :max_attempts, :integer
  end
end
