class AddCompositeIndexesForCourseAndScenario < ActiveRecord::Migration
  def change
    remove_index :courses, column: :title
    add_index :courses, [:university_id, :title], unique: true

    remove_index :scenarios, column: :name
    add_index :scenarios, [:university_id, :name], unique: true
  end
end
