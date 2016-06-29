module StudentSessionExpirer
  def expire_ongoing_student_sessions(showing)
      return unless showing.expired? # Safety check

      showing.student_sessions.each do |session|
        if session.ongoing?
          session.update_column(:status, ShowingSession.statuses[:expired])
          session.update_column(:attempts_remaining, 0)
        end
      end

      students_without_sessions = showing.course.students.find_all { |student| has_no_session(showing, student) }

      students_without_sessions.each do |student|
        create_expired_session_for(student, showing)
      end
  end

  private
  def has_no_session(showing, student)
    showing.sessions.none? { |session| session.user.id == student.id }
  end

  def create_expired_session_for(student, showing)
    showing_session = ShowingSession.new(
        {
            showing_id: showing.id,
            attempts_remaining: 0,
            node_id: showing.scenario.root_node_id,
            user_id: student.id,
            status: ShowingSession.statuses[:expired]
        })

    unless showing_session.save(:validate => false)
      render json: showing_session.errors, status: unprocessable_entity
    end
  end
end