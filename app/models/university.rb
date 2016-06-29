class University < ActiveRecord::Base
  has_many :users
  has_many :scenarios
  has_many :courses

  validates :name, presence: true, uniqueness: true
end
