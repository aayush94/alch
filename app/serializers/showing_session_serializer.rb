class ShowingSessionSerializer < ActiveModel::Serializer
  attributes :id, :status, :attempts_remaining, :previous_justification

  has_one :node, serializer: NodeSessionSerializer
  has_one :showing

  def previous_justification
    node_decisions = Decision.where(:showing_session_id => object.id, :from_node_id => object.node.id)

    unless node_decisions.blank?
      latest_decision = node_decisions.sort_by { |decision| decision.created_at }.last

      latest_decision.justification
    end
  end
end