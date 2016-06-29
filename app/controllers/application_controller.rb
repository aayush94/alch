class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  # Provides access to current_user in app/serializers/*
  serialization_scope :view_context

  def angular
    render 'layouts/application'
  end

  # Default behavior if cancan detects an authorization problem
  rescue_from CanCan::AccessDenied do |exception|
    head :unauthorized 
  end

  def record_not_found(error)
    render :json => {:error => error.message}, :status => :not_found
  end
end
