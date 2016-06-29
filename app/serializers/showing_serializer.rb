class ShowingSerializer < ActiveModel::Serializer
  attributes :id, :start_time, :end_time, :is_graded, :max_attempts, :display_name, :user_session, :hidden
  has_one :scenario
  has_one :course

  def is_graded
    object.is_graded ||= false
  end

  def display_name
    object.display_name ||= object.scenario.name
  end

  def user_session
    session = ShowingSession.find_by(:user_id => scope.current_user.id, :showing_id => object.id)
    {:id => session.id, :status => session.status, :attempts_remaining => session.attempts_remaining} unless session.nil?
  end
end
