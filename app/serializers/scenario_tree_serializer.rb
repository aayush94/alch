class ScenarioTreeSerializer < ActiveModel::Serializer
  attributes :id, :choices

  has_many :nodes, serializer: NodeTreeSerializer

  # Returns all complete choices for this scenario
  def choices
    choices = serialization_options[:choices]
    ActiveModel::ArraySerializer.new(choices, each_serializer: ChoiceTreeSerializer)
  end
end
