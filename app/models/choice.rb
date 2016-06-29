class Choice < ActiveRecord::Base
  validate :num_choices, on: :create

  attr_accessor :width, :label #hack

  belongs_to :node
  belongs_to :to_node, :class_name => 'Node'

  amoeba do
    enable
  end

  private
  def num_choices
    if self.node.choices.count >= 5
      errors.add(:node, "cannot have more than 5 choices.")
    end
  end
end
