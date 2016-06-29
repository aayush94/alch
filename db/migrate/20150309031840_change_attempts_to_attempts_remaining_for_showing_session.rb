class ChangeAttemptsToAttemptsRemainingForShowingSession < ActiveRecord::Migration
  def change
    rename_column :showing_sessions, :attempts, :attempts_remaining
  end
end
