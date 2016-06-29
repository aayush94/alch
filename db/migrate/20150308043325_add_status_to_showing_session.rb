class AddStatusToShowingSession < ActiveRecord::Migration
  def change
    add_column :showing_sessions, :status, :integer, default: 0
  end
end
