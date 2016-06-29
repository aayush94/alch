class ScenariosController < ApplicationController
  include ScenarioCopier
  before_action :set_scenario, only: [:show, :copy, :edit, :tree, :update, :destroy]
  respond_to :json

  # GET /scenarios
  def index
    authorize! :index, Scenario

    render json: Scenario.where(:locked => false, :university => current_user.university)
  end

  # GET /scenarios/1
  def show
    authorize! :read, @scenario

    render json: @scenario
  end

  # GET /scenarios/1/edit
  def edit
  end

  def tree
    authorize! :read, @scenario
    render json: @scenario, choices: @scenario.complete_choices, serializer: ScenarioTreeSerializer
  end

  # POST /scenarios
  def create
    authorize! :create, Scenario

    scenario = Scenario.new(scenario_params)
    scenario.university = current_user.university
    scenario.archived = false
    scenario.locked = false

    Scenario.transaction do
      begin
        save_scenario_with_root_node(scenario)
      rescue ActiveRecord::RecordInvalid => invalid
        render json: invalid.record.errors, status: :unprocessable_entity and return
      end

      render json: scenario, status: :created
    end
  end

  # POST /scenarios/1/copy
  def copy
    authorize! :copy, @scenario

    unless scenario_params[:name]
      render json: {error: 'Must provide a new scenario name.'}, status: :unprocessable_entity and return
    end

    scenario_copy = copy_scenario(@scenario, {:copy_name => scenario_params[:name], :description => scenario_params[:description]}); return if performed?

    render json: scenario_copy, status: :created
  end

  # PATCH/PUT /scenarios/1
  def update
    authorize! :update, @scenario

    if @scenario.locked
      render json: {error: 'Cannot update a locked scenario.'}, status: :bad_request and return
    end

    if @scenario.update(scenario_params)
      head :no_content
    else
      render json: @scenario.errors, status: :unprocessable_entity
    end
  end

  private
    def set_scenario
      @scenario = Scenario.find(params[:id])
    end

    def scenario_params
      params.require(:scenario).permit(:name, :description, :archived, :root_node_id)
    end

    def save_scenario_with_root_node(scenario)
      scenario.save!
      root_node = initialize_root_node(scenario)
      scenario.update!(root_node_id: root_node.id)
    end

    def initialize_root_node(scenario)
      node = Node.create!(:scenario_id => scenario.id)
      node.update!(is_start: true, label: 1)
      node
    end
end
