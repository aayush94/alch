class ChoiceTreeSerializer < ActiveModel::Serializer
  attributes :from, :to, :width, :label, :title

  def width
    if object.width
      max_width = 10
      object.width > max_width ? max_width : object.width
    end
  end

  def from
    object.node_id
  end

  def to
    object.to_node_id
  end

  def title
    "This choice was taken #{object.width} time(s)"
  end
end
