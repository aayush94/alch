class Node < ActiveRecord::Base
  validates :body,
            :length => { maximum: 300 }
  validate :not_goal_and_failure, on: [:create, :update]

	belongs_to :scenario
  belongs_to :asset
	has_many :choices, dependent: :destroy

  amoeba do
    enable
  end

  def leaf?
    self.choices.none? {|choice| choice.to_node_id.present?}
  end

  def regular?
    !self.is_failure and !self.is_goal and !self.is_start
  end

  def not_goal_and_failure
    if self.is_goal and self.is_failure
      errors.add(:node, "cannot be set as both a goal and failure.")
    end
  end
end
