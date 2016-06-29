class Enrollment < ActiveRecord::Base

  # A user may only be enrolled once in any one class
  validates_uniqueness_of :user_id, scope: :course_id, 
    message: "You have already enrolled in this course."

  belongs_to :user
  belongs_to :course
end
