class ChoiceSerializer < ActiveModel::Serializer
  attributes :id, :text, :node_id, :to_node_id, :to_node_label

  def to_node_label
    unless object.to_node.nil?
      object.to_node.label || object.to_node.id
    end
  end
end
