class ScenarioSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :archived, :root_node_id, :locked, :warnings, :display_name

  def display_name
    if object.showings.any? then object.showings.first.display_name else object.name end
  end
end
