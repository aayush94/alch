class UniversitiesController < ApplicationController

  def index
    render json: University.all.order(:name)
  end
end
