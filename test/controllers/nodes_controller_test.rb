require 'test_helper'

class NodesControllerTest < ActionController::TestCase
  setup do
    @node = nodes(:one)
    @a_scenario_id = scenarios(:one).id

    @instructor = users(:instructor)
    sign_in @instructor
  end

  test 'should get all scenario nodes' do
    expected_nodes = [nodes(:three), nodes(:four)]

    get :index, :scenario_id => scenarios(:two).id

    assert_response :ok

    assert_equal serialize(expected_nodes, NodeSerializer, @instructor), response.body
  end

  test 'should fail to index scenario nodes when permissions are insufficient' do
    sign_in(users(:student))

    get :index, :scenario_id => scenarios(:one).id

    assert_response :unauthorized
  end

  test 'should create node with default values' do
    assert_difference('Node.count') do
      post :create, :scenario_id => @a_scenario_id
    end

    assert_response :success

    created_node = Node.find_by_scenario_id(@a_scenario_id)

    expected_node = Node.new(
        :id => created_node.id,
        :scenario_id => @a_scenario_id,
        :title => '',
        :body => '',
        :is_start => false,
        :is_goal => false,
        :is_failure => false,
        :requires_justification => false
      )

    assert_equal(expected_node, created_node)
  end

  test 'should increment node label when creating a new node' do
    scenario_id = scenarios(:complete_scenario).id

    assert_difference('Node.count') do
      post :create, :scenario_id => scenario_id
    end

    assert_response :success

    created_node = Node.order("created_at").last

    assert_equal(created_node.label, 4)
  end

  test 'should decrement only greater node labels when deleting a node' do
    scenario_id = scenarios(:complete_scenario).id
    node_to_delete = nodes(:complete_scenario_goal)

    assert_difference('Node.count', -1) do
      delete :destroy, :scenario_id => scenario_id, :id => node_to_delete.id
    end

    assert_response :no_content

    start_node = Node.find(nodes(:complete_scenario_root).id)
    updated_node = Node.find(nodes(:complete_scenario_failure).id)

    assert_equal start_node.label, 1
    assert_equal updated_node.label, 2
  end

  test 'should fail to create node when set as both goal and failure' do
    post :create, :scenario_id => @a_scenario_id, :is_goal => true, :is_failure => true

    assert_response :unprocessable_entity
  end

  test 'should fail to create node when permissions are insufficient' do
    sign_out @instructor
    student = users(:student)
    sign_in(student)

    post :create, :scenario_id => @a_scenario_id

    assert_response :unauthorized
  end

  test 'should fail to create node when scenario does not exist' do
    post :create, :scenario_id => -1

    assert_response :not_found
  end

  test 'should get node' do
    get :show, :scenario_id => @a_scenario_id, :id => @node.id

    assert_response :ok

    the_response = JSON.parse(response.body)
    expected_node = nodes(:one)

    assert_equal expected_node['id'], the_response['id']
  end

  test 'should fail to get node when permissions are insufficent' do
    sign_in(users(:student))
    get :show, :scenario_id => @a_scenario_id, :id => @node.id

    assert_response :unauthorized
  end

  test 'should include scenario warnings in response when they exist' do
    get :show, :scenario_id => @a_scenario_id, :id => @node.id

    assert_response :ok

    body = JSON.parse(response.body)

    assert body['scenario']['warnings'].any?
  end

  test 'should not include scenario warnings in response when they do not exist' do
    get :show, :scenario_id => scenarios(:complete_scenario).id, :id => nodes(:complete_scenario_root).id

    assert_response :ok

    body = JSON.parse(response.body)

    assert body['scenario']['warnings'].blank?
  end

  test 'should fail to get node when node does not belong to scenario' do
    get :show, :scenario_id => scenarios(:two).id, :id => @node.id

    assert_response :not_found
  end

  test 'should fail to get node when id does not exist' do
    get :show, :scenario_id => @a_scenario_id, :id => -1

    assert_response :not_found
  end

  test 'should fail to get node when scenario does not exist' do
    get :show, :scenario_id => -1, :id => @node.id

    assert_response :not_found
  end

  test 'should update node' do
    put :update, :scenario_id => @a_scenario_id, :id => @node.id,
        :title => 'ABC', :body => 'The alphabet rocks.', :is_goal => true

    updated_node = Node.find(@node.id)

    expected_node = Node.new(
        :id => @node.id,
        :scenario_id => @a_scenario_id,
        :title => 'ABC',
        :body => 'The alphabet rocks.',
        :is_start => false,
        :is_goal => true,
        :is_failure => false,
        :requires_justification => false
    )

    assert_equal(expected_node, updated_node)

    assert_response :ok
  end

  test 'should fail to update node when body longer than 300 characters' do
    put :update, :scenario_id => @a_scenario_id, :id => @node.id,
        :body => "A" * 301

    assert_response :unprocessable_entity
  end

  test 'should delete node choices when updating as a goal node' do
    the_node = nodes(:two)
    assert_not_empty the_node.choices

    put :update, :scenario_id => @a_scenario_id, :id => the_node.id, :is_goal => true
    assert_response :ok

    updated_node = Node.find(the_node.id)
    assert_empty updated_node.choices
  end

  test 'should delete node choices when updating as a failure node' do
    the_node = nodes(:two)
    assert_not_empty the_node.choices

    put :update, :scenario_id => @a_scenario_id, :id => the_node.id, :is_failure => true
    assert_response :ok

    updated_node = Node.find(the_node.id)
    assert_empty updated_node.choices
  end

  test 'should fail to update node when set as both goal and failure' do
    put :update, :scenario_id => @a_scenario_id, :id => @node.id,
        :node => { :is_goal => true, :is_failure => true }

    assert_response :ok
  end

  test 'should fail to update node when node does not belong to scenario' do
    put :update, :scenario_id => scenarios(:two).id, :id => @node.id,
        :node => { :title => 'ABC', :body => 'The alphabet rocks.', :is_goal => true }

    assert_response :not_found
  end

  test 'should fail to update node when scenario does not exist' do
    put :update, :scenario_id => -1, :id => @node.id,
        :node => { :title => 'ABC', :body => 'The alphabet rocks.', :is_goal => true }

    assert_response :not_found
  end

  test 'should fail to update node when node does not exist' do
    put :update, :scenario_id => @a_scenario_id, :id => -1,
        :node => { :title => 'ABC', :body => 'The alphabet rocks.', :is_goal => true }

    assert_response :not_found
  end

  test 'should fail to update node when permissions are insufficient' do
    sign_out @instructor
    student = users(:student)
    sign_in(student)

    put :update, :scenario_id => @a_scenario_id, :id => @node.id,
        :node => { :title => 'ABC', :body => 'The alphabet rocks.', :is_goal => true }

    assert_response :unauthorized
  end

  test 'should delete node and all of its choices' do
    assert_difference('Node.count', -1) do
      delete :destroy, :scenario_id => @a_scenario_id, :id => @node.id
    end

    assert_response :no_content

    assert_raises ActiveRecord::RecordNotFound do
      Node.find(@node.id)
    end

    @node.choices.each do |choice|
      assert_raises ActiveRecord::RecordNotFound do
        Choice.find(choice.id)
      end
    end
  end

  test 'should remove links between nodes when to node is deleted' do
    delete :destroy, :scenario_id => @a_scenario_id, :id => @node.id
    assert_response :no_content

    the_connected_node = Node.find(nodes(:two).id)

    assert_equal nodes(:two).choices.length, the_connected_node.choices.length
    the_connected_node.choices.each do |choice|
      assert_nil choice.to_node_id
    end
  end

  test 'should fail to delete start node' do
    delete :destroy, :scenario_id => @a_scenario_id, :id => nodes(:start_node)

    assert_response :bad_request
  end

  test 'should fail to delete node when permissions are insufficient' do
    sign_out(@instructor)
    student = users(:student)
    sign_in(student)

    delete :destroy, :scenario_id => @a_scenario_id, :id => @node.id

    assert_response :unauthorized
  end
end
