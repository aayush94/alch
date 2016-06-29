class ChoicesController < ApplicationController
  before_action :set_choice, only: [:show, :edit, :update, :destroy]

  def index
    node = Node.find(params[:node_id])
    render json: node.choices
  end

  # GET /scenarios/1/nodes/1/choices/1.json
  def show
    render json: @choice
  end

  def edit
  end

  # POST /scenarios/1/nodes/1/choices.json
  def create
    authorize! :create, Choice

    node = Node.find(params[:node_id])

    if node.scenario.locked
      render json: {error: 'Cannot add choices to a showing.'}, status: :bad_request and return
    end

    choice = node.choices.build(choice_params)

    if choice.save
      render json: choice, status: :created
    else
      render json: choice.errors, status: :unprocessable_entity
    end
  end

  # PUT /scenarios/1/nodes/1/choices/1.json
  def update
    authorize! :write, Choice

    if choice_params[:to_node_id]
      validate_to_node(params[:scenario_id], choice_params[:to_node_id]); return if performed?
    end

    if @choice.update(choice_params)
      render json: @choice, status: :no_content
    else
      render json: @choice.errors, status: :unprocessable_entity
    end
  end

  # DELETE /choices/1.json
  def destroy
    authorize! :destroy, Choice

    if @choice.node.scenario.locked
      render json: {error: 'Cannot remove choices from a showing.'}, status: :bad_request and return
    end

    @choice.destroy

    head :no_content
  end

  private
    def set_choice
      node = Node.find(params[:node_id])
      @choice = node.choices.find(params[:id])
    end

    def choice_params
      params.require(:choice).permit(:node_id, :to_node_id, :text)
    end

    def validate_to_node(scenario_id, to_node_id)
      if to_node_id.to_s == params[:node_id]
        render json: {error: 'Cannot link a node to itself.'}, status: :bad_request
      end

      scenario = Scenario.find(scenario_id)
      # raises ActiveRecord::RecordNotFound and caught in ApplicationController on failure
      scenario.nodes.find(to_node_id)
    end
end
