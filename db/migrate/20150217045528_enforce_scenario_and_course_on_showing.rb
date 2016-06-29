class EnforceScenarioAndCourseOnShowing < ActiveRecord::Migration
  def change
    change_column_null :showings, :course_id, false
    change_column_null :showings, :scenario_id, false
  end
end
