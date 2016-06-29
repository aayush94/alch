class NodeTreeSerializer < ActiveModel::Serializer
  # For use with the ScenarioTreeSerializer, just
  # returns the necessities for the tree viewer.
  attributes :id, :label, :title, :color, :body

  def label
    "#{object.label || object.id}"
  end

  def color
    if object.is_failure?
      { background: "#f49998" }
    elsif object.is_start?
      { background: "#6b6b6b" }
    elsif object.is_goal?
      { background: "#a2c582" }
    else
      { background: "#7d9ac1" }
    end
  end
end
