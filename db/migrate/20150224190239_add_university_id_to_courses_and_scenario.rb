class AddUniversityIdToCoursesAndScenario < ActiveRecord::Migration
  def change
    add_column :courses, :university_id, :integer
    add_column :scenarios, :university_id, :integer
  end
end
