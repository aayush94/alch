class CreateEnrollments < ActiveRecord::Migration
  def change
    create_table :enrollments do |t|
      t.integer :course_id
      t.integer :user_id

      t.timestamps null: false

    end

    add_index :enrollments, :course_id
    add_index :enrollments, :user_id
  end
end
