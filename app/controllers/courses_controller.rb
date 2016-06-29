class CoursesController < ApplicationController
  include StudentSessionExpirer
  before_action :set_course, only: [:show, :report, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /courses
  def index
    enrolled_courses = Course.joins(:enrollments)
                             .where(:enrollments => { user_id: current_user.id}, active: true)

    render json: enrolled_courses, status: :ok
  end

  # GET /courses/1
  def show
    render json: @course
  end

  # POST /courses
  def create
    authorize! :create, Course

    @course = Course.new(course_params)
    @course.university = current_user.university

    Course.transaction do
      begin
        @course.save!
        Enrollment.create({course_id: @course.id, user_id: current_user.id})
      rescue ActiveRecord::RecordInvalid => invalid
        render json: invalid.record.errors, status: :unprocessable_entity and return
      end
    end

    render json: @course, status: :created
  end

  # PATCH/PUT /courses/1
  def update
    authorize! :write, @course

    if @course.update(course_params)
      render json: @course, status: :ok
    else
      render json: @course.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /courses/1/enroll
  def enroll
    authorize! :enroll, Course

    course = Course.where({ access_code: params[:access_code], active: true }).first

    if course
      enrollment = Enrollment.new({ course_id: course.id, user_id: current_user.id })

      if enrollment.save
        render json: enrollment.course, status: :ok
      else
        render json: enrollment.errors, status: :unprocessable_entity
      end
    else
      render json: { error: "No course with that access code could be found" }, status: :not_found
    end
  end

  # GET /courses/1/report
  def report
    authorize! :report, @course

    expired_showings = @course.showings.find_all { |showing| showing.expired? }

    expired_showings.each do |showing|
      expire_ongoing_student_sessions(showing)
    end

    render json: @course, status: :ok,
        report: build_course_report,
        students: students_with_averages,
        serializer: CourseReportSerializer
  end

  # DELETE /courses/1
  def destroy
    authorize! :write, @course

    if @course.update_attribute(:active, false)
      head :no_content
    else
      render json: @course.errors, status: :unprocessable_entity
    end
  end

  private
    def set_course
      @course = Course.find(params[:id])
      authorize! :read, @course
    end

    def build_course_report
      course_average = get_course_average

      {:courseAverage => course_average}
    end

  def get_course_average(sid = nil)
    total_average = 0
    num_showings = 0

    @course.showings.each do |showing|
      showing_average = showing.get_average(sid)

      unless showing_average == -1 # Only include showings with completed data
        total_average += showing_average
        num_showings += 1
      end
    end

    num_showings == 0 ? "N/A" : ( (total_average / num_showings) * 100).round(1)
  end

  def students_with_averages
      students = []

      @course.students.each do |student|
        student_average = get_course_average(student.id)

        student_report = {:user_id => student[:id], :username => student[:username], :average => student_average}
        students << student_report
      end

      students
    end

    def course_params
      params.require(:course).permit(:title, :active)
    end
end
