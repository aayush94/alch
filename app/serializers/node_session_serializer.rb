class NodeSessionSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :is_start, :is_goal, :is_failure, :requires_justification
  has_many :choices
  has_one :asset
end
