class ShowingSessionsController < ApplicationController
  respond_to :json

  before_action :set_session, only: [:decide, :show, :restart]
  before_action :verify_showing_is_active!, only: [:decide, :show, :restart]

  def show
    render json: @show_session
  end

  def create
    showing = Showing.find(session_params[:showing_id])
    root_node = Node.find(showing.scenario.root_node_id)

    show_session = ShowingSession.new({
      showing_id: showing.id,
      attempts_remaining: showing.max_attempts,
      node_id: root_node.id,
      user_id: current_user.id
    })

    authorize! :create, show_session

    if show_session.save
      render json: show_session, status: :created
    else
      render json: { error: show_session.errors }, status: :unprocessable_entity
    end
  end

  def decide
    @to_node = Node.find(session_params[:to_node_id])

    if invalid_choice?
      render json: { errors: "Not a valid decision from this node" }, status: :unprocessable_entity and return
    end

    ShowingSession.transaction do
      begin
        create_decision! unless practicing?
        @show_session.node = @to_node
        @show_session.save!
      rescue ActiveRecord::RecordInvalid => invalid
        render json: invalid.record.errors, status: :unprocessable_entity and return
      end
    end

    render json: @show_session, status: :ok
  end

  def restart
    if practicing? or @show_session.node.is_failure? or !current_user.student?
      root_node = Node.find(@show_session.showing.scenario.root_node_id)
      @show_session.update_attribute(:node, root_node)
      render json: @show_session, status: :ok
    else
      render json: { error: "Cannot restart unless at a failed node" }, status: :bad_request
    end
  end

  private
    def create_decision!
      justification = @show_session.node.requires_justification ? session_params[:justification] : nil

      Decision.create!({
        showing_session: @show_session,
        from_node: @show_session.node,
        to_node: @to_node,
        justification: justification
      })
    end

    def session_params
      params.permit(:session_id, :showing_id, :to_node_id, :justification)
    end

    def set_session
      @show_session = ShowingSession.find(session_params[:session_id])
      authorize! :read, @show_session
    end

    def verify_showing_is_active!
      # handle special case where showing has expired since last read
      if current_user.student? and @show_session.ongoing? and @show_session.showing.expired?
        @show_session.update_column(:status, ShowingSession.statuses[:expired])
        @show_session.update_column(:attempts_remaining, 0)
        render json: @show_session, serializer: ShowingSessionClosedSerializer, status: :ok
      elsif not @show_session.ongoing?
        render json: @show_session, serializer: ShowingSessionClosedSerializer, status: :ok
      end
    end

    def practicing?
      @show_session.showing.practice? or !current_user.student?
    end

    def invalid_choice?
      @show_session.node.choices.where(to_node_id: @to_node.id).empty?
    end
end
