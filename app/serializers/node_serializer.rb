class NodeSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :is_start, :is_goal, :is_failure, :requires_justification, :label
  has_one :scenario
  has_many :choices
  has_one :asset

  def label
    object.label ||= object.id
  end
end
