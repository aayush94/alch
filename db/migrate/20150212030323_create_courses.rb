class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :title
      t.string :access_code

      t.timestamps null: false
    end
    add_index :courses, :access_code, unique: true, length: 10
  end
end
