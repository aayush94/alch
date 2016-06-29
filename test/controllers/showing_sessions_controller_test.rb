require 'test_helper'

class ShowingSessionsControllerTest < ActionController::TestCase
  setup do
    @node = nodes(:one)
    @scenario = scenarios(:one)
    @showing = showings(:one)
    @complete_showing = showings(:complete_showing)

    @scenario.root_node_id = @node.id
    @scenario.save

    @instructor = users(:instructor)
    @student = users(:student)
    sign_in @student
  end

  test "should get session" do
    @session = showing_sessions(:justify_session)
    get :show, session_id: @session.id

    assert_response :ok

    expected = serialize(@session, ShowingSessionSerializer, @student)
    assert_equal expected, response.body
  end

  test "should get simplified session response when status is not ongoing" do
    @session = showing_sessions(:justify_session)
    @session.status = ShowingSession.statuses[:failed]
    @session.save

    get :show, session_id: @session.id

    assert_response :ok

    expected = serialize(@session, ShowingSessionClosedSerializer, @student)
    assert_equal expected, response.body
  end

  test "should not get session when doesn't belong to student" do
    sign_out @student
    sign_in users(:student2)

    @session = showing_sessions(:justify_session)
    get :show, session_id: @session.id

    assert_response :unauthorized
  end

  test "should create" do
    assert_difference('ShowingSession.count', 1) do
      post :create, showing_id: @showing.id
    end

    assert_response :created
  end

  test "should not create if user is not enrolled in scenario's class" do
    sign_out @student
    sign_in users(:student2) #not enrolled in any classes

    post :create, showing_id: @showing.id

    assert_response :unauthorized
  end

  test "should not create if showing does not exist" do
    post :create, showing_id: -1337

    assert_response :not_found
  end

  test "should not create if showing has expired" do
    @complete_showing.start_time = 2.days.ago #dope
    @complete_showing.end_time = 1.days.ago
    @complete_showing.save

    post :create, showing_id: @complete_showing.id

    assert_response :unprocessable_entity
  end

  test "should not create if user already has a session for this showing" do
    assert_difference('ShowingSession.count', 1) do
      post :create, showing_id: @showing.id
    end

    assert_response :success

    assert_no_difference('ShowingSession.count') do
      post :create, showing_id: @showing.id
    end

    assert_response :unprocessable_entity
  end

  test "should make a decision" do
    @session = showing_sessions(:ongoing)
    assert_difference("Decision.count", 1) do
      post :decide, {
        to_node_id: @session.node.choices.first.to_node_id,
        session_id: @session.id
      }
    end

    assert_response :ok

    @session.node = Node.find(@session.node.choices.first.to_node_id)
    expected = serialize(@session, ShowingSessionSerializer, @student)
    assert_equal response.body, expected

    @decision = Decision.where(showing_session: @session).last
    assert @decision.neutral?
  end

  test "should decide 'failed' and decrement attempt" do
    @session = showing_sessions(:ongoing_with_failure)
    post :decide, {
      to_node_id: nodes(:complete_scenario_failure).id,
      session_id: @session.id
    }

    assert_response :ok
    assert_equal @session.showing.max_attempts - 1, ShowingSession.find(@session.id).attempts_remaining
  end

  test "should not decrement attempt if practice session" do
    @session = showing_sessions(:practice_session)
    post :decide, {
      to_node_id: Node.find_by_title("I am a failure").id,
      session_id: @session.id
    }

    assert_response :ok
    assert_equal @session.showing.max_attempts, ShowingSession.find(@session.id).attempts_remaining
  end

  test 'should not set practice sessions to completed when goal node is reached' do
    @session = showing_sessions(:practice_to_be_success)

    post :decide, {
                    to_node_id: Node.find_by_title("Absolute success").id,
                    session_id: @session.id
                }

    assert_response :ok
    assert ShowingSession.find(@session.id).ongoing?
  end

  test "should not decide if session is practice" do
    @session = showing_sessions(:practice_session)

    assert_no_difference("Decision.count") do
      post :decide, {
        to_node_id: @session.node.choices.first.to_node_id,
        session_id: @session.id,
      }
    end

    @session.node = Node.find(@session.node.choices.first.to_node_id)
    expected = serialize(@session, ShowingSessionSerializer, @student)

    assert_response :ok
    assert_equal response.body, expected
  end

  test 'should not decrement attempts if instructor reaches failure' do
    sign_in(@instructor)
    @session = showing_sessions(:instructor_ongoing)
    post :decide, {
                    to_node_id: nodes(:complete_scenario_failure).id,
                    session_id: @session.id
                }

    assert_response :ok
    assert_equal @session.showing.max_attempts, ShowingSession.find(@session.id).attempts_remaining
  end

  test "should set status to failed when max attempts reached" do
    @session = showing_sessions(:ongoing_with_failure)
    @session.attempts_remaining = 1
    @session.save

    post :decide, {
      to_node_id: nodes(:complete_scenario_failure).id,
      session_id: @session.id
    }

    assert_response :ok

    session = ShowingSession.find(@session.id)

    assert session.failed?
    assert_equal session.attempts_remaining, 0
  end

  test "should create 'success' decision and set status to completed " do
    @session = showing_sessions(:to_be_success)

    assert_difference("Decision.count", 1) do
      post :decide, {
        to_node_id: Node.find_by_title("Absolute success").id,
        session_id: @session.id
      }
    end

    assert_response :ok

    assert Decision.where(showing_session: @session).last.success?
    assert ShowingSession.find(@session.id).completed?
  end

  test 'should not set status to completed when an instructor reaches a goal node' do
    sign_in(@instructor)
    @session = showing_sessions(:instructor_to_be_success)

    post :decide, {
      to_node_id: Node.find_by_title("Absolute success").id,
      session_id: @session.id
    }

    assert_response :ok
    assert ShowingSession.find(@session.id).ongoing?
  end

  test "should set status to expired and attempts remaining to zero if showing time has expired" do
    @session = showing_sessions(:ongoing_student_session_for_expired_showing)

    assert_no_difference "Decision.count" do
      post :decide, {
        to_node_id: @session.node.id,
        session_id: @session.id
      }
    end

    assert_response :ok

    @session.status = ShowingSession.statuses[:expired]
    @session.attempts_remaining = 0
    expected = serialize(@session, ShowingSessionClosedSerializer, @student)

    assert_equal expected, response.body
  end

  test "should not expire ongoing instructor sessions when they play an expired showing" do
    sign_in(@instructor)
    the_session = showing_sessions(:ongoing_instructor_session_for_expired_showing)

    get :show, :session_id => the_session.id

    assert_response :ok

    the_session_status = ShowingSession.find(the_session.id).status

    assert_equal ShowingSession.statuses[:ongoing], ShowingSession.statuses[the_session_status]
  end

  test "should reject decision if justification required and not given" do
    @session = showing_sessions(:justify_session)

    assert_no_difference "Decision.count" do
      post :decide, {
        to_node_id: Node.find_by_title("six").id,
        session_id: @session.id
      }
    end

    assert_response :unprocessable_entity
  end

  test "decide with justification" do
    @session = showing_sessions(:justify_session)

    assert_difference("Decision.count", 1) do
      post :decide, {
        to_node_id: Node.find_by_title("six").id,
        session_id: @session.id,
        justification: "i like turtles"
      }
    end

    assert_response :ok
    refute Decision.find_by_justification("i like turtles").nil?
  end

  test "should ignore provided justification when node does not require it" do
    @session = showing_sessions(:to_be_success)

    assert_difference("Decision.count", 1) do
      post :decide, {
          to_node_id: Node.find_by_title("Absolute success").id,
          session_id: @session.id,
          justification: "i like turtles"
      }
    end

    assert_response :ok

    the_decision = Decision.order("created_at").last

    assert_nil the_decision.justification
  end

  test "should return simplified request if session status is not active" do
    @session = showing_sessions(:ongoing)
    @session.status = ShowingSession.statuses[:completed]
    @session.save

    assert_no_difference "Decision.count" do
      post :decide, {
        to_node_id: Node.find_by_title("iJustify").id,
        session_id: @session.id
      }
    end
  
    assert_response :ok

    expected = serialize(@session, ShowingSessionClosedSerializer, @student)
    assert_equal expected, response.body
  end

  test "should not make a decision if session does not exist" do
    post :decide, session_id: -1337

    assert_response :not_found
  end

  test "should restart node when at a failure node" do
    @session = showing_sessions(:at_failure_session)
    post :restart, session_id: @session.id

    assert_response :ok

    @session.node_id = @session.showing.scenario.root_node_id
    expected = serialize(@session, ShowingSessionSerializer, @student)

    assert_equal response.body, expected
  end

  test "should not restart when at a non failure node" do
    @session = showing_sessions(:ongoing)
    post :restart, session_id: @session.id

    assert_response :bad_request

    # ensure nothing has changed
    resulting_session = ShowingSession.find(@session.id)
    assert_equal @session.attempts_remaining, resulting_session.attempts_remaining
    assert_equal @session.node, resulting_session.node
  end

  test 'should allow instructors to restart when at a non failure node' do
    sign_in(@instructor)

    @session = showing_sessions(:instructor_ongoing)
    post :restart, session_id: @session.id

    assert_response :ok

    @session.node_id = @session.showing.scenario.root_node_id
    expected = serialize(@session, ShowingSessionSerializer, @instructor)

    assert_equal response.body, expected
  end

  test 'should allow restarting at a non failure node when showing is for practice' do
    @session = showing_sessions(:practice_session)
    post :restart, session_id: @session.id

    assert_response :ok

    @session.node_id = @session.showing.scenario.root_node_id
    expected = serialize(@session, ShowingSessionSerializer, @student)

    assert_equal response.body, expected
  end

  test 'should include most recent justification for a node when it requires it' do
    get :show, :session_id => showing_sessions(:justify_session).id

    assert_response :ok

    the_session = JSON.parse(response.body)
    the_previous_justification = decisions(:decision_with_justification).justification

    assert_equal the_previous_justification, the_session['previous_justification']
  end

  test 'should not include most recent justification for a node when it does not require it' do
    get :show, :session_id => showing_sessions(:ongoing).id

    assert_response :ok

    the_session = JSON.parse(response.body)

    assert_nil the_session['previous_justification']
  end
end
