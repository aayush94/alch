class AddIndexToCourseTitle < ActiveRecord::Migration
  def change
    add_index :courses, :title, unique: true
  end
end
