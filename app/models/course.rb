class Course < ActiveRecord::Base
  before_create :set_access_token

  validates :title,
    presence: true,
    uniqueness: { :scope => :university, :case_sensitive => false },
    length: { in: 4..140 }

  validates_presence_of :university, on: :create

  has_many :enrollments
  has_many :showings, -> { visible }
  has_many :users, :through => :enrollments
  has_many :scenarios, :through => :showings

  belongs_to :university

  def students
    self.users.where(role: User.roles[:student])
  end

  private
    def set_access_token
      self.access_code = SecureRandom.hex(10)
    end
end
