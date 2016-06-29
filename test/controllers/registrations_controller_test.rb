require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase

  def setup
    # This is required when testing devise controllers
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  # TODO wtf devise, let me hit your routes
  # test "should not allow sign up if no university is specified" do
  #   user = { email: "test@test.com", username: "test_user", role: User.roles[:student] }
  #   post :create, user: user
  #   assert_response :unprocessable_entity
  # end

  test "should_elevate_user" do
  	@instructor = users(:instructor)
    sign_in @instructor

    @student = users(:student)
    assert_equal(User.roles[:student], User.roles[@student.role])

    put 'elevate_to_instructor', {'email' => @student.email}
    assert_response :success

    @student.reload
    assert_equal(User.roles[:instructor], User.roles[@student.role])
  end

  test "should fail to elevate when user does not exist" do
    @instructor = users(:instructor)
    sign_in @instructor

  	put 'elevate_to_instructor', {'email' => 'idontexist@lmao.com'}

  	assert_response :missing
  end

  test "should fail to elevate user when user is already above instructor" do
  	@instructor = users(:instructor)
    sign_in @instructor

  	put 'elevate_to_instructor', {'email' => users(:admin).email}

  	assert_response(400)
  end

  test "should fail to elevate when permissions are insufficient" do
  	@student = users(:student)
  	sign_in @student

  	put 'elevate_to_instructor', {'email' => users(:student2).email}

  	assert_response(401)
  end
end
