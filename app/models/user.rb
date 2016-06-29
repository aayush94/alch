class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  enum role: [:student, :ta, :instructor, :admin]

  after_initialize :set_default_role, :if => :new_record?

  validates :username, presence: true, uniqueness: true, length: { in: 4..25 }
  validates :university, presence: true

  has_many :enrollments
  has_many :courses, through: :enrollments
  has_many :sessions, class_name: "ShowingSession"
  has_many :decisions, through: :sessions

  belongs_to :university

  # Checks if a user's role is greater than
  # or equal to the operation being attempted
  def role?(base_role)
    User.roles[self.role] >= User.roles[base_role]
  end

  private
    def set_default_role
      self.role ||= :student
    end

end
