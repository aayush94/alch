ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
require "active_model_serializers"

class ActiveSupport::TestCase
  include Devise::TestHelpers

  # Color things up
  MiniTest::Reporters.use!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def serialize(data, serializer, current_user = nil)
    current_user_stub = CurrentUserStub.new(current_user)

    if data.respond_to?('each')
      ActiveModel::ArraySerializer.new(data, each_serializer: serializer, scope: current_user_stub).to_json
    else
      serializer.new(data, scope: current_user_stub).to_json
    end
  end

  # Stub class required by certain serializers
  # that use `current_user`
  class CurrentUserStub
    def initialize(user)
      @current_user = user
    end

    def current_user
      @current_user
    end
  end


end
