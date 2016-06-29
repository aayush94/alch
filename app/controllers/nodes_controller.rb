class NodesController < ApplicationController
  before_action :set_node, only: [:show, :update, :destroy]
  respond_to :json

  def index
    authorize! :index, Scenario

    scenario_nodes = Scenario.find(params[:scenario_id]).nodes

    render json: scenario_nodes
  end

  # GET /scenarios/1/nodes/1
  def show
    authorize! :read, @node.scenario

    validate_node_scenario

    render json: @node
  end

  def edit
  end

  # PUT /scenarios/1/nodes/1
  def update
    authorize! :write, Node

    np = node_params
    sanitize!(np)

    Node.transaction do
      begin
        @node.update!(np)
        if @node.is_goal or @node.is_failure
          delete_choices(@node) unless @node.choices.blank?
        end

        validate_node_scenario
      rescue ActiveRecord::RecordInvalid => invalid
        render json: invalid.record.errors, status: :unprocessable_entity and return
      end
    end

    render json: @node, status: :ok
  end

  def validate_node_scenario
    warnings = []
    scenario = @node.scenario

    if scenario.unconnected_nodes?
      warnings << "Scenario cannot have unconnected nodes."
    end

    if scenario.incomplete_choices?
      warnings << "Scenario must connect all choices to another node or be removed."
    end

    if scenario.no_goal_nodes?
      warnings << "Scenario must have at least one goal node."
    end

    if scenario.regular_leaf_nodes?
      warnings << "Scenario cannot have non goal or failure leaf nodes."
    end

    if scenario.unlabeled_choices?
      warnings << "Scenario must have text for all of its choices."
    end

    @node.scenario.warnings = warnings
  end

  # DELETE /scenarios/1/nodes/1
  def destroy
    authorize! :destroy, Node

    if @node.is_start
      render json: {error: 'Start nodes cannot be deleted.'}, status: :bad_request and return
    end

    Node.transaction do
      begin
        @node.destroy
        remove_to_links(@node)

        if @node.label
          update_node_labels(@node)
        end
      rescue ActiveRecord::RecordInvalid => errors
        render json: errors, status: :unprocessable_entity and return
      end
    end

    render json: :head, status: :no_content
  end

  # POST /scenarios/1/nodes.json
  def create
    authorize! :create, Node

    scenario = Scenario.find(params[:scenario_id])
    node = scenario.nodes.build(node_params)

    if scenario_nodes_have_labels(scenario)
      assign_label_to_node(node, scenario)
    end

    save_node node
  end

  private
    def set_node
      scenario = Scenario.find(params[:scenario_id])
      @node = scenario.nodes.find(params[:id])
    end

    def update_node_labels(deleted_node)
      scenario_nodes = deleted_node.scenario.nodes

      scenario_nodes.where("label > ?", deleted_node.label).each do |node|
        node.decrement!(:label)
      end
    end

    def assign_label_to_node(node, scenario)
      current_max_label = scenario.nodes.max_by {|node| node.label.to_f}.label
      node.label = current_max_label+1
    end

    def scenario_nodes_have_labels(scenario)
      scenario.root_node.label
    end

    def node_params
      params.permit(:scenario_id, :title, :body, :is_goal, :is_failure, :requires_justification, :choices, :asset_id)
    end

    def save_node(node)
      if node.save
        render json: node, status: :created
      else
        render json: node.errors, status: :unprocessable_entity
      end
    end

    def delete_choices(node)
      node.choices.destroy_all
    end

    def remove_to_links(node)
      Choice.where(:to_node => node).update_all(:to_node_id => nil)
    end

    def sanitize!(node)
      node.delete(:choices) if node[:choices].nil?
    end
end
