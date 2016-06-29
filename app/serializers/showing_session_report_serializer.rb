class ShowingSessionReportSerializer < ActiveModel::Serializer
  attributes :user_id, :username, :num_failures, :status, :color

  def username
    object.user.username
  end

  def num_failures
    object.num_failures
  end

  def color
    "red"
  end

end
