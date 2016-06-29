class DecisionTreeSerializer < ActiveModel::Serializer
  attributes :from, :to, :label, :color, :title, :user_id, :width

  def from
    object.from_node_id
  end

  def to
    object.to_node_id
  end

  def label
    if object.justification
      object.justification[0..8] + "..."
    else
      ""
    end
  end

  def title
    object.justification
  end

  def color
    "red"
  end

  def user_id
    object.showing_session.user_id
  end

end
