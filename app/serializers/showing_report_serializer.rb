class ShowingReportSerializer < ActiveModel::Serializer
  attributes :id, :choices, :sessions, :nodes, :decisions

  def attributes
    data = super
    data[:summaries] = serialization_options[:summaries]
    data
  end

  def sessions
    sessions = serialization_options[:sessions]
    ActiveModel::ArraySerializer.new(sessions, each_serializer: ShowingSessionReportSerializer)
  end

  def decisions
    decisions = serialization_options[:decisions]
    if decisions
      ActiveModel::ArraySerializer.new(decisions, each_serializer: DecisionTreeSerializer)
    else
      nil
    end
  end

  def choices
    choices = serialization_options[:choices]
    ActiveModel::ArraySerializer.new(choices, each_serializer: ChoiceTreeSerializer)
  end

  def nodes
    nodes = serialization_options[:nodes]
    ActiveModel::ArraySerializer.new(nodes, each_serializer: NodeTreeSerializer)
  end

end
