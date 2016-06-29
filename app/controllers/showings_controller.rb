class ShowingsController < ApplicationController
  include ScenarioCopier
  include StudentSessionExpirer

  before_action :set_showing, only: [:show, :edit, :update, :destroy, :report, :student_report]
  before_action :assert_ids, only: [:create]

  # GET /courses/1/showings.json
  def index
    course = Course.find(params[:course_id])

    authorize! :index, course

    showings = course.showings
    update_expired_sessions(showings)

    if current_user.student?
      active_showings = showings.find_all { |showing| showing.active? }

      render json: active_showings, status: :ok and return
    end

    render json: showings, status: :ok
  end

  # GET courses/1/showings/1
  def show
    authorize! :read, @showing

    render json: @showing
  end

  # GET /showings/new
  def new
  end

  # GET /showings/1/edit
  def edit
  end

  # POST /courses/1/showings
  def create
    scenario = Scenario.find(showing_params[:scenario_id])
    authorize! :copy, scenario

    if scenario.locked
      render json: {error: 'Cannot create a showing for a locked scenario.'}, status: :bad_request and return
    end

    course = Course.find(params[:course_id])
    showing = course.showings.build(showing_params)
    authorize! :create, showing

    Showing.transaction do
      begin
        showing.save!

        copy_name = "#{scenario.name} #{Time.now.to_i}"
        scenario_copy = copy_scenario(scenario, {:locked => true, :copy_name => copy_name})

        showing.update!(:scenario_id => scenario_copy.id, :display_name => scenario.name)
      rescue ActiveRecord::RecordInvalid => invalid
        render json: invalid.record.errors, status: :unprocessable_entity and return
      end
    end

    render json: showing, status: :created
  end

  # PATCH/PUT /showings/1
  def update
    authorize! :update, @showing

    if @showing.expired?
      render json: {error: 'Cannot update an expired showing.'}, status: :bad_request and return
    end

    filtered_params = filter_update_params showing_params

    if @showing.update(filtered_params)
      render json: @showing, status: :ok
    else
      render json: @showing.errors, status: :unprocessable_entity
    end
  end

  # DELETE /showings/1
  def destroy
  end

  def report
    authorize! :report, @showing

    if @showing.expired?
      expire_ongoing_student_sessions(@showing)
    end

    render json: @showing, status: :ok,
           summaries: calc_summaries,
           choices: @showing.choices_with_stats,
           nodes: @showing.scenario.nodes,
           sessions: @showing.student_sessions,
           serializer: ShowingReportSerializer
  end

  def student_report
    authorize! :read, @showing

    if params[:sid].nil?
      render json: { error: "Invalid student id" }, status: :unprocessable_entity and return
    end

    render json: @showing, status: :ok,
           choices: @showing.scenario.complete_choices,
           decisions: @showing.decisions_with_stats_for(params[:sid]),
           nodes: @showing.scenario.nodes,
           sessions: @showing.student_sessions,
           serializer: ShowingReportSerializer

  end

  private

    def calc_summaries
      report = {
        class_average_num_failures: @showing.avg_student_failures,
        max_attempts_allowed: @showing.max_attempts
      }

      session_types = @showing.student_sessions_by_type
      session_types.keys.each { |type|
        report["num_students_#{type}"] = session_types[type].count
      }

      report
    end

    def update_expired_sessions(showings)
      expired_showings = showings.find_all { |showing| showing.expired? }

      expired_showings.each do |expired_showing|
        expire_ongoing_student_sessions(expired_showing)
      end
    end

    def set_showing
      if current_user.role? :instructor
        @showing = Showing.find(params[:id])
      else
        @showing = Showing.visible.find(params[:id])
      end
    end

    def assert_ids
      course_id = params[:course_id]
      scenario_id = showing_params[:scenario_id]

      if course_id.nil? or scenario_id.nil?
        render json: {error: 'Must provide both a scenario and course ID.'}, status: :unprocessable_entity
      end
    end

    def showing_params
      params.require(:showing).permit(:start_time, :end_time, :scenario_id, :is_graded, :max_attempts, :sids, :hidden)
    end

    def filter_update_params(showing_params)
      showing_params.slice(:start_time, :end_time, :hidden)
    end
end
