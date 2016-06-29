require 'test_helper'

class CoursesControllerTest < ActionController::TestCase
  setup do
    @course = courses(:one)

    @instructor = users(:instructor)
    sign_in @instructor
  end

  def enroll_in(course)
    put :enroll, id: course.id, access_code: course.access_code
  end

  test "a student should be enrolled in a course when a valid access_code is used" do
    @student = users(:student2)
    sign_in @student

    enroll_in(@course)
    assert_response :ok
  end

  test "a student should not be able to enroll in the same course twice" do
    @student = users(:student2)
    sign_in @student

    enroll_in(@course)
    assert_response :ok

    enroll_in(@course)
    assert_response :unprocessable_entity 
    assert response.body.include? "already enrolled"
  end

  test "student should not be able to enroll in a course with an invalid access_code" do
    @student = users(:student2)
    sign_in @student

    invalid_access_code = @course.access_code + "1"
    @course.access_code = invalid_access_code

    enroll_in(@course)
    assert_response :not_found
    assert response.body.include? "access code"
  end

  test "a student should be able to view all courses they are enrolled and none they are not" do
    @student = users(:student2)
    sign_in @student

    course_one = courses(:one)
    course_two = courses(:two)

    enroll_in(course_one)
    enroll_in(course_two)
    # note: not enrolled in courses(:three)

    courses = [courses(:full_report_testing), course_one, course_two]
    expected = serialize(courses, CourseSerializer, @student)

    get :index

    assert_response :success
    assert_equal response.body, expected
  end

  test "a course should not include hidden showings" do
    @student = users(:student)
    sign_in @student

    @course = courses(:one)
    get :show, { id: @course.id }

    assert_response :success
    res = JSON.parse(response.body)
    count = res["showings"].count

    @showing = showings(:to_be_hidden)
    @showing.update_attribute(:hidden, true)

    get :show, { id: @course.id }

    assert_response :success
    res = JSON.parse(response.body)
    assert_equal count - 1, res["showings"].count

    @showing.update_attribute(:hidden, false)
  end

  test "a student should be able to view a course when they are enrolled" do
    @student = users(:student2)
    sign_in @student

    enroll_in(@course)
    expected = serialize(@course, CourseSerializer, @student)
    
    get :show, { id: @course.id }

    assert_response :ok
    assert_equal response.body, expected
  end

  test "a student viewing a course should not see an access_code" do
    @student = users(:student)
    sign_in @student

    enroll_in(@course)
    
    get :show, { id: @course.id }

    assert_response :ok
    refute response.body.include? "access_code"
  end

  test "a student should not be able to view a course when they are not enrolled" do
    @student = users(:student2)
    sign_in @student

    get :show, { id: @course.id }
    
    assert_response :unauthorized
  end

  test "a student should not be able to update a course when they are not enrolled" do
    @student = users(:student2)
    sign_in @student

    put :update, { id: @course.id, course: { title: "new title" } }
    
    assert_response :unauthorized
    assert_not_equal Course.find(@course.id).title, "new title"
  end

  test "a student should not be able to update a course even if enrolled" do
    @student = users(:student2)
    sign_in @student

    enroll_in(@course)
    put :update, { id: @course.id, course: { title: "new title" } }
    
    assert_response :unauthorized
    assert_not_equal Course.find(@course.id).title, "new title"
  end

  test "a student should not be able to create a course" do
    @student = users(:student2)
    sign_in @student

    new_course = { course: { title: "new course" } }
    post :create, new_course

    assert_response :unauthorized
    assert Course.find_by_title("new course").nil?
  end

  test "a student should not be able to destroy a course even if enrolled" do
    @student = users(:student2)
    sign_in @student

    enroll_in(@course)
    post :destroy, id: @course.id

    assert_response :unauthorized
    assert Course.find(@course.id).active?
  end

  test "courses should only return active courses by default" do
    course_one = @course
    course_two = courses(:two)
    course_three = courses(:three)

    enroll_in(course_one)
    enroll_in(course_two)
    enroll_in(course_three)

    get :index
    result = JSON.parse(response.body)

    put :update, id: result.last["id"], course: { active: false }

    get :index
    assert_response :success
    assert_equal 3, JSON.parse(response.body).count
  end

  test "an instructor should not be able to update a course they are not enrolled in" do
    sign_in users(:instructor2)
    put :update, { id: @course.id, course: @course.attributes }
    
    assert_response :unauthorized
    assert_not_equal Course.find(@course.id).title, "new title"
  end

  test "an instructor should be able to update a course they are enrolled in" do
    enroll_in(@course)
    put :update, { id: @course.id, course: { title: "new title" } }
    
    assert_response :ok
    assert_equal Course.find(@course.id).title, "new title"
  end

  test "an instructor should be able to create a new course" do
    new_course = { course: { title: "new course" } }
    post :create, new_course

    assert_response :success
    assert response.body.include? "access_code"
    assert Course.find_by_title("new course").present?
  end

  test "an instructor should not be able to create a course with the same name at the same university" do
    new_course = { course: { title: "new course"} }

    post :create, new_course
    assert_response :success

    post :create, new_course
    assert_response :unprocessable_entity
  end

  test "two courses with the same name should be able to exist at different universities" do
    new_course = { course: { title: "new course"} }

    post :create, new_course
    assert_response :success

    sign_out @instructor

    @instructor_sfu = users(:instructor_sfu)
    sign_in @instructor_sfu

    post :create, new_course
    assert_response :success
  end

  test 'should still fail to create course when name exists with different case' do
    post :create, { :course => { :title => @course.title.upcase } }

    assert_response :unprocessable_entity
  end

  test "an instructor should not be able to destroy a course they are not enrolled in" do
    sign_in users(:instructor2)
    post :destroy, { id: @course.id }

    assert_response :unauthorized
    assert Course.find(@course.id).active?
  end

  test "an instructor should be able to deactivate a course they are enrolled in" do
    enroll_in(@course)
    post :destroy, { id: @course.id }

    assert_response :success
    refute Course.find(@course.id).active?
  end

  test 'should get full course report' do
    get :report, :id => courses(:full_report_testing).id

    assert_response :ok

    course_report = JSON.parse(response.body)

    report = course_report['report']
    student_one = course_report['students'].find { |student| student['user_id'] == users(:student).id }
    student_two = course_report['students'].find { |student| student['user_id'] == users(:student2).id }

    assert_equal 40.0, report['courseAverage']
    assert_equal 80.0, student_one['average']
    assert_equal 0.0, student_two['average']
  end

  test 'should expire ongoing student sessions when reporting all course showings' do
    get :report, :id => courses(:one).id

    assert_response :ok

    the_session = ShowingSession.find(showing_sessions(:ongoing_student_session_for_expired_showing).id)

    assert the_session.expired?
  end

  test 'should create an expired student session when reporting all course showings for ones they never started' do
    student = users(:student3)

    the_expired_showing = Showing.find(showings(:expired_showing).id)

    assert_empty the_expired_showing.sessions_for(student.id)

    get :report, :id => courses(:one).id

    assert_response :ok

    the_created_session = the_expired_showing.sessions_for(student.id).first

    assert_not_nil the_created_session
    assert_equal the_created_session.attempts_remaining, 0
    assert the_created_session.expired?
  end

  test 'should list students averages with no graded sessions as N/A' do
    get :report, :id => courses(:full_report_testing).id

    assert_response :ok

    course_report = JSON.parse(response.body)

    student_three = course_report['students'].find { |student| student['user_id'] == users(:student3).id }

    assert_equal "N/A", student_three['average']
  end

  test 'should not include instructors in course report' do
    get :report, :id => courses(:full_report_testing).id

    assert_response :ok

    course_report = JSON.parse(response.body)

    assert course_report['students'].none? { |student| student['user_id'] == users(:instructor).id }
  end

  test 'should not be able to get a report when permissions are insufficient' do
    sign_in(users(:student))
    get :report, :id => courses(:full_report_testing).id

    assert_response :unauthorized
  end
end
