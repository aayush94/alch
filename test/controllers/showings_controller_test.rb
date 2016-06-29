require 'test_helper'

class ShowingsControllerTest < ActionController::TestCase
  setup do
    @showing = showings(:one)
    @a_scenario = scenarios(:one)
    @complete_scenario = scenarios(:complete_scenario)
    @a_course = courses(:one)

    @instructor = users(:instructor) # Instructor is enrolled in course one
    sign_in @instructor
  end

  test 'should get showing' do
    get :show, :course_id => @a_course.id, :id => @showing.id

    assert_response :ok

    assert_equal serialize(@showing, ShowingSerializer, @instructor), response.body
  end

  test 'should include session in showing response when it exists' do
    sign_in(users(:student))

    get :show, :course_id => @a_course.id, :id => showings(:active_showing).id

    assert_response :ok

    showing_session = JSON.parse(response.body)['user_session']

    assert_not_nil showing_session
    assert_equal showing_session['status'], 'ongoing'
  end

  test 'should not include session in showing response when it does not exist' do
    sign_in(users(:student))

    get :show, :course_id => courses(:three).id, :id => showings(:course_3_showing_1).id

    assert_response :ok

    showing_session = JSON.parse(response.body)['user_session']

    assert_nil showing_session
  end

  test 'should not include hidden showings' do
    sign_in(users(:student))

    get :show, :course_id => @a_course.id, :id => showings(:hidden_showing).id

    assert_response :not_found
  end

  test 'should include hidden showings' do
    sign_in(users(:instructor))

    get :show, :course_id => @a_course.id, :id => showings(:hidden_showing).id

    assert_response :ok
  end

  test 'should expire ongoing student sessions when indexing expired showings' do
    sign_in(users(:student))

    get :index, :course_id => @a_course.id

    assert_response :ok

    the_session = ShowingSession.find(showing_sessions(:ongoing_student_session_for_expired_showing).id)

    assert the_session.expired?
  end

  test 'should expire ongoing student sessions when getting a report for an expired showing' do
    get :report, { id: showings(:expired_showing).id }

    assert_response :ok

    the_session = ShowingSession.find(showing_sessions(:ongoing_student_session_for_expired_showing).id)

    assert the_session.expired?
  end

  test 'should create an expired student session when indexing an expired showing they never started' do
    student = users(:student3)
    sign_in(student)

    the_expired_showing = Showing.find(showings(:expired_showing).id)

    assert_empty the_expired_showing.sessions_for(student.id)

    get :index, :course_id => @a_course.id

    assert_response :ok

    the_created_session = the_expired_showing.sessions_for(student.id).first

    assert_not_nil the_created_session
    assert_equal the_created_session.attempts_remaining, 0
    assert the_created_session.expired?
  end

  test 'should create an expired student session when getting a report for an expired showing they never started' do
    student = users(:student3)

    the_expired_showing = Showing.find(showings(:expired_showing).id)

    assert_empty the_expired_showing.sessions_for(student.id)

    get :report, { id: showings(:expired_showing).id }

    assert_response :ok

    the_created_session = the_expired_showing.sessions_for(student.id).first

    assert_not_nil the_created_session
    assert_equal the_created_session.attempts_remaining, 0
    assert the_created_session.expired?
  end

  test 'should not expire completed student sessions when indexing expired showings' do
    sign_in(users(:student))

    get :index, :course_id => @a_course.id

    assert_response :ok

    the_session = ShowingSession.find(showing_sessions(:completed_student_session_for_expired_showing).id)

    assert the_session.completed?
  end

  test 'should not expire completed student sessions when reporting expired showings' do
    get :report, { id: showings(:expired_showing).id }

    assert_response :ok

    the_session = ShowingSession.find(showing_sessions(:completed_student_session_for_expired_showing).id)

    assert the_session.completed?
  end

  test 'should not expire failed student sessions when indexing expired showings' do
    sign_in(users(:student))

    get :index, :course_id => @a_course.id

    assert_response :ok

    the_session = ShowingSession.find(showing_sessions(:failed_student_session_for_expired_showing).id)

    assert the_session.failed?
  end

  test 'should not expire failed student sessions when reporting expired showings' do
    get :report, { id: showings(:expired_showing).id }

    assert_response :ok

    the_session = ShowingSession.find(showing_sessions(:failed_student_session_for_expired_showing).id)

    assert the_session.failed?
  end

  test 'should not expire ongoing instructor sessions when indexing expired showings' do
    get :index, :course_id => @a_course.id

    assert_response :ok

    the_session = ShowingSession.find(showing_sessions(:ongoing_instructor_session_for_expired_showing).id)

    assert the_session.ongoing?
  end

  test 'should not expire ongoing instructor sessions when getting a report for an expired showing' do
    get :report, { id: showings(:expired_showing).id }

    assert_response :ok

    the_session = ShowingSession.find(showing_sessions(:ongoing_instructor_session_for_expired_showing).id)

    assert the_session.ongoing?
  end

  test 'should update showing start and end time when it has not started' do
    the_new_start_date = 2.days.from_now
    the_new_end_date = 10.days.from_now
    showing_params = {:start_time => the_new_start_date, :end_time => the_new_end_date}
    showing_id = showings(:has_not_started).id

    put :update, :course_id => @a_course.id, :id => showing_id, :showing => showing_params

    assert_response :ok

    the_updated_showing = Showing.find(showing_id)

    assert_equal the_updated_showing.start_time.to_a, the_new_start_date.to_a
    assert_equal the_updated_showing.end_time.to_a, the_new_end_date.to_a
  end

  test 'should filter out attributes when updating a showing' do
    the_scenario_id = 16
    showing_params = {:scenario_id => the_scenario_id}
    showing_id = showings(:has_not_started).id

    put :update, :course_id => @a_course.id, :id => showing_id, :showing => showing_params

    assert_response :ok

    the_updated_showing = Showing.find(showing_id)

    assert_not_equal the_updated_showing.scenario_id, the_scenario_id
  end

  test 'should fail to update showing start time when it has started' do
    showing = showings(:complete_showing)
    update_params = {:start_time => 1.days.from_now}

    put :update, :course_id => @a_course.id, :id => showing.id, :showing => update_params

    assert_response :unprocessable_entity
  end

  test 'should fail to update showing when it is expired' do
    showing = showings(:expired_showing)
    update_params = {:start_time => 5.days.ago, :end_time => 4.days.from_now}

    put :update, :course_id => @a_course.id, :id => showing.id, :showing => update_params

    assert_response :bad_request
  end

  test 'should fail to update showing when end date is before start date' do
    showing = showings(:has_not_started)
    update_params = {:start_time => 2.days.from_now, :end_time => 1.days.from_now}

    put :update, :course_id => @a_course.id, :id => showing.id, :showing => update_params

    assert_response :unprocessable_entity
  end

  test 'should fail to update showing when start date is before current date' do
    showing = showings(:has_not_started)
    update_params = {:start_time => 2.days.ago}

    put :update, :course_id => @a_course.id, :id => showing.id, :showing => update_params

    assert_response :unprocessable_entity
  end

  test 'should fail to get showing when not enrolled in the course' do
    sign_in(users(:student2))

    get :show, :course_id => @a_course.id, :id => @showing.id

    assert_response :unauthorized
  end

  test 'should fail to update showing with insufficient permissions' do
    sign_out(@instructor)
    sign_in(users(:student))

    put :update, :course_id => @a_course.id, :id => @showing.id, :showing => {:is_graded => true}

    assert_response :unauthorized
  end

  test 'should create showing with cloned and locked scenario' do
    assert_difference('Showing.count', 1) do
      post :create, :course_id => @a_course.id,
           showing: { scenario_id: @complete_scenario.id, max_attempts: 5, is_graded: true, start_time: 2.days.from_now, end_time: 4.days.from_now }
    end

    assert_response :created

    created_showing = Showing.order('created_at').last

    assert_not_equal created_showing.scenario.id, @complete_scenario.id
    assert created_showing.scenario.name.include? @complete_scenario.name
    assert_equal created_showing.display_name, @complete_scenario.name
    assert created_showing.scenario.locked
  end

  test 'should fail to create showing when start time is before current date' do
    post :create, :course_id => @a_course.id,
         :showing => { scenario_id: @complete_scenario.id, max_attempts: 5, is_graded: true, start_time: 5.days.ago, end_time: 2.days.ago }

    assert_response :unprocessable_entity
  end

  test 'should fail to create showing when start time is after end time' do
    post :create, :course_id => @a_course.id,
         :showing => { scenario_id: @complete_scenario.id, max_attempts: 5, is_graded: true, start_time: 3.days.from_now, end_time: 2.days.from_now }

    assert_response :unprocessable_entity
  end

  test 'should fail to create showing when scenario is missing a goal node' do
    post :create, :course_id => @a_course.id,
         showing: { scenario_id: scenarios(:missing_goal).id, start_time: 2.days.from_now, end_time: 4.days.from_now }

    assert_response :unprocessable_entity
  end

  test 'should fail to create showing when scenario has orphan nodes' do
    post :create, :course_id => @a_course.id,
         showing: { scenario_id: scenarios(:orphan_nodes).id, start_time: 2.days.from_now, end_time: 4.days.from_now }

    assert_response :unprocessable_entity
  end

  test 'should fail to create showing when scenario has incomplete choices' do
    post :create, :course_id => @a_course.id,
         showing: { scenario_id: scenarios(:incomplete_choices).id, start_time: 2.days.from_now, end_time: 4.days.from_now }

    assert_response :unprocessable_entity
  end

  test 'should fail to create a showing when scenario has unlabeled choices' do
    post :create, :course_id => @a_course.id,
         showing: {scenario_id: scenarios(:unlabeled_choices).id, start_time: 2.days.from_now, end_time: 4.days.from_now }

    assert_response :unprocessable_entity
  end

  test 'should fail to create showing when scenario has regular leaf nodes' do
    post :create, :course_id => @a_course.id,
         showing: { scenario_id: scenarios(:regular_leaf_nodes).id, start_time: 2.days.from_now, end_time: 4.days.from_now }

    assert_response :unprocessable_entity
  end

  test 'should fail to create showing when scenario is locked' do
    post :create, :course_id => @a_course.id,
         showing: { scenario_id: scenarios(:locked).id, start_time: 2.days.from_now, end_time: 4.days.from_now }

    assert_response :bad_request
  end

  test 'should fail to create showing when course does not exist' do
    post :create, :course_id => -1, showing: { scenario_id: @a_scenario.id, start_time: 2.days.from_now, end_time: 4.days.from_now }

    assert_response :not_found
  end

  test 'should fail to create showing when scenario does not exist' do
    post :create, :course_id => @a_course.id, showing: { scenario_id: -1, start_time: 2.days.from_now, end_time: 4.days.from_now }

    assert_response :not_found
  end

  test 'should fail to create showing when scenario is not provided' do
    post :create, :course_id => @a_course.id, showing: { start_time: 2.days.from_now, end_time: 4.days.from_now }

    assert_response :unprocessable_entity
  end

  test 'should fail to create showing when instructor is not enrolled in course' do
    post :create, :course_id => courses(:two).id, showing: { scenario_id: @a_scenario.id, start_time: 2.days.from_now, end_time: 4.days.from_now }

    assert_response :unauthorized
  end

  test 'should fail to create showing with enrolled student' do
    sign_out(@instructor)
    student = users(:student)
    sign_in(student) # Student is enrolled in course one

    post :create, :course_id => @a_course.id, showing: { scenario_id: @a_scenario.id, start_time: 2.days.from_now, end_time: 4.days.from_now }

    assert_response :unauthorized
  end

  test 'should fail to create graded showing when max attempts is not provided' do
    post :create, :course_id => @a_course.id,
         showing: { scenario_id: @a_scenario.id, is_graded: true, start_time: 2.days.from_now, end_time: 4.days.from_now }

    assert_response :unprocessable_entity
  end

  test 'should fail to create graded showing when max attempts greater than 1000' do
    post :create, :course_id => @a_course.id,
         showing: { scenario_id: @a_scenario.id, max_attempts: 1001, is_graded: true, start_time: 2.days.from_now, end_time: 4.days.from_now }

    assert_response :unprocessable_entity
  end

  test 'should fail to create graded showing when max attempts zero' do
    post :create, :course_id => @a_course.id,
         showing: { scenario_id: @a_scenario.id, max_attempts: 0, is_graded: true, start_time: 2.days.from_now, end_time: 4.days.from_now }

    assert_response :unprocessable_entity
  end

  test 'should fail to create graded showing when max attempts is less than zero' do
    post :create, :course_id => @a_course.id,
         showing: { scenario_id: @a_scenario.id, max_attempts: -1, is_graded: true, start_time: 2.days.from_now, end_time: 4.days.from_now }

    assert_response :unprocessable_entity
  end

  test 'should still create a practice showing when max attempts is not provided' do
    assert_difference('Showing.count', 1) do
      post :create, :course_id => @a_course.id,
           showing: { scenario_id: scenarios(:complete_scenario).id, is_graded: false, start_time: 2.days.from_now, end_time: 4.days.from_now }
    end

    assert_response :created
  end

  test 'should get all showings for a course' do
    the_course = courses(:three) # Instructor is enrolled in course 3
    expected_showings = [showings(:course_3_showing_1), showings(:course_3_showing_2)]

    get :index, :course_id => the_course.id

    assert_response :ok
    assert_equal response.body, serialize(expected_showings, ShowingSerializer, @instructor)
  end

  test 'should only index showings that have started when logged in as a student' do
    sign_in(users(:student))

    get :index, :course_id => @a_course.id

    assert_response :ok

    the_showings = JSON.parse(response.body)

    assert the_showings.none? { |showing| showing['id'] == showings(:has_not_started).id }
  end

  test 'should include showings that have not started when indexing as an instructor' do
    get :index, :course_id => @a_course.id

    assert_response :ok

    the_showings = JSON.parse(response.body)

    assert the_showings.one? { |showing| showing['id'] == showings(:has_not_started).id }
  end

  test 'should fail to get showings for a course when not enrolled' do
    the_unenrolled_course = courses(:two)

    get :index, :course_id => the_unenrolled_course.id

    assert_response :unauthorized
  end

  test "should return all decisions" do
    @showing = showings(:report_showing)

    get :report, { id: @showing.id }

    assert_response :ok

    res = JSON.parse(response.body)

    assert_equal @showing.scenario.complete_choices.count, res["choices"].count
    assert_equal @showing.scenario.nodes.count, res["nodes"].count
    assert_equal @showing.sessions.count, res["sessions"].count

    @showing.sessions.each { |expected_session|
      assert res["sessions"].any? { |actual_session|
      (expected_session.showing.max_attempts - expected_session.attempts_remaining) == actual_session["num_failures"]
      }
    }
  end

  test "should return number of each session type and average failures" do
    @showing = showings(:report_showing)

    get :report, { id: @showing.id }

    assert_response :ok
    res = JSON.parse(response.body)

    avg = @showing.decisions.reduce(0) { |sum, decision|
          sum + decision.showing_session.num_failures
        } / @showing.decisions.count

    assert_equal avg, res["summaries"]["class_average_num_failures"]

    session_types = @showing.student_sessions_by_type

    session_types.keys.each { |type|
      assert res["summaries"].has_key? "num_students_#{type}"
      assert_equal session_types[type].count, res["summaries"]["num_students_#{type}"]
    }

  end

  test "should return no decisions when no sids given" do
    @student = users(:student)
    @showing = showings(:report_showing)

    get :student_report, id: @showing.id, sid: []

    assert_response :ok

    res = JSON.parse(response.body)
    assert_equal 0, res["decisions"].count

    assert_equal @showing.scenario.complete_choices.count, res["choices"].count
    assert_equal @showing.scenario.nodes.count, res["nodes"].count
    assert_equal @showing.sessions.count, res["sessions"].count
  end

  test "should return no decisions for sids not in the class" do
    @student = users(:student)
    @showing = showings(:report_showing)

    get :student_report, id: @showing.id, sid: 1337

    assert_response :ok

    res = JSON.parse(response.body)
    assert_equal 0, res["decisions"].count

    assert_equal @showing.scenario.complete_choices.count, res["choices"].count
    assert_equal @showing.scenario.nodes.count, res["nodes"].count
    assert_equal @showing.sessions.count, res["sessions"].count
  end

  test "should return decisions for a single user" do
    @student = users(:student)
    @showing = showings(:report_showing)

    get :student_report, id: @showing.id, sid: @student.id

    assert_response :ok

    res = JSON.parse(response.body)

    assert_equal @showing.scenario.complete_choices.count, res["choices"].count
    assert_equal @showing.scenario.nodes.count, res["nodes"].count
    assert_equal @showing.student_sessions.count, res["sessions"].count
    assert_equal @student.decisions.count, res["decisions"].count

    @student.decisions.each { |expected_decision| 
      assert res["decisions"].any? { |actual_decision|
        expected_decision.from_node_id == actual_decision["from"] and
          expected_decision.to_node_id == actual_decision["to"]
      }
    }
  end

end
