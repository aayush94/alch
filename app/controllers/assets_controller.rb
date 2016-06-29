class AssetsController < ApplicationController
  before_action :set_asset, only: [:show, :edit, :update, :destroy]

  # GET /assets
  def index
    render json: Asset.all, status: :ok
  end

  # GET /assets/1
  def show
    render json: @asset, status: :ok
  end

  # GET /assets/new
  def new
  end

  # GET /assets/1/edit
  def edit
  end

  # POST /assets
  def create
    authorize! :create, Asset

    asset = Asset.new(asset_params)

    if asset.save
      render json: asset, status: :created
    else
      render json: asset.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /assets/1
  def update
  end

  # DELETE /assets/1
  def destroy
  end

  private
    def set_asset
      @asset = Asset.find(params[:id])
    end

    def asset_params
      params.permit(:image)
    end
end
