require 'test_helper'

class ChoicesControllerTest < ActionController::TestCase
  setup do
    @scenario = scenarios(:one)
    @node = nodes(:one)
    @choice = choices(:one)

    @instructor = users(:instructor)
    sign_in @instructor
  end

  test 'should get all choices for node' do
    expected_choices = [choices(:three), choices(:two)]

    get :index, :scenario_id => @scenario.id, :node_id => nodes(:two)

    assert_response :ok

    assert_equal serialize(expected_choices, ChoiceSerializer, @instructor), response.body
  end

  test 'should get choice' do
    get :show, :scenario_id => @scenario.id, :node_id => @node.id, :id => @choice.id

    assert_response :ok

    assert_equal serialize(@choice, ChoiceSerializer, @instructor), response.body
  end

  test 'should fail to get choice when does not belong to node' do
    get :show, :scenario_id => @scenario.id, :node_id => nodes(:two).id, :id => @choice.id

    assert_response :not_found
  end

  test 'should create choice' do
    the_choice = { :text => 'Dip an oreo', :to_node_id => 10 }

    assert_difference('Choice.count') do
      post :create, :scenario_id => @scenario.id, :node_id => @node.id, choice: the_choice
    end

    assert_response :created

    created_choice = Choice.find_by_text(the_choice[:text])
    expected_choice = Choice.new(:id => created_choice.id,
                                 :text => the_choice[:text],
                                 :to_node_id => the_choice[:to_node_id])

    assert_equal expected_choice, created_choice
  end

  test 'should fail to create choice when node does not exist' do
    post :create, :scenario_id => @scenario.id, :node_id => -1, choice: { :text => 'cool' }

    assert_response :not_found
  end

  test 'should fail to create choice when scenario is locked' do
    post :create, :scenario_id => scenarios(:locked).id, :node_id => nodes(:locked_scenario_node).id, choice: { :text => 'cool'}

    assert_response :bad_request
  end

  test 'should fail to create choice with insufficient permissions' do
    sign_out(@instructor)
    student = users(:student)
    sign_in(student)

    post :create, :scenario_id => @scenario.id, :node_id => @node.id, choice: {:text => 'blah'}

    assert_response :unauthorized
  end

  test 'should update choice' do
    put :update, :scenario_id => @scenario.id, :node_id => @node.id, :id => @choice.id,
        choice: { :to_node_id => nodes(:two).id }

    assert_response :no_content

    updated_choice = Choice.find_by_text(@choice.text)
    assert_equal serialize(updated_choice, ChoiceSerializer, @instructor), response.body
  end

  test 'should fail to update choice when to node does not exist' do
    put :update, :scenario_id => @scenario.id, :node_id => @node.id, :id => @choice.id,
        choice: { :to_node_id => -1 }

    assert_response :not_found
  end

  test 'should fail to update choice when to node is the same as choice node' do
    put :update, :scenario_id => @scenario.id, :node_id => @node.id, :id => @choice.id,
        choice: { :to_node_id => @node.id }

    assert_response :bad_request
  end

  test 'should fail to update choice when to node does not belong to scenario' do
      put :update, :scenario_id => @scenario.id, :node_id => @node.id, :id => @choice.id,
          choice: { :to_node_id => nodes(:three).id }

      assert_response :not_found
  end

  test 'should fail to update choice with insufficient permissions' do
    sign_out(@instructor)
    student = users(:student)
    sign_in(student)

    put :update, :scenario_id => @scenario.id, :node_id => @node.id, :id => @choice.id,
        choice: { :to_node_id => nodes(:one).id }

    assert_response :unauthorized
  end

  test 'should delete choice' do
    assert_difference('Choice.count', -1) do
      delete :destroy, :scenario_id => @scenario.id, :node_id => @node.id, :id => @choice.id
    end

    assert_response :no_content

    assert_raises ActiveRecord::RecordNotFound do
      Choice.find(@choice.id)
    end
  end

  test 'should fail to create choice when node already has five choices' do
    post :create, :scenario_id => @scenario.id, :node_id => nodes(:with_five_choices).id,
         :choice => { :text => "Roll some pizza dough" }

    assert_response :unprocessable_entity
  end

  test 'should fail to delete choice when scenario is locked' do
    delete :destroy, :scenario_id => scenarios(:locked).id,
           :node_id => nodes(:locked_scenario_node).id,
           :id => choices(:locked_scenario_choice).id

    assert_response :bad_request
  end

  test 'should fail to delete choice with insufficient permissions' do
    sign_out(@instructor)
    student = users(:student)
    sign_in(student)

    delete :destroy, :scenario_id => @scenario.id, :node_id => @node.id, :id => @choice.id

    assert_response :unauthorized
  end
end
