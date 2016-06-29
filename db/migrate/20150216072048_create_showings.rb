class CreateShowings < ActiveRecord::Migration
  def change
    create_table :showings do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.belongs_to :scenario, index: true
      t.belongs_to :course, index: true

      t.timestamps null: false
    end
    add_foreign_key :showings, :scenarios
    add_foreign_key :showings, :courses
  end
end
