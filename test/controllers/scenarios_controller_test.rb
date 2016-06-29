require 'test_helper'

class ScenariosControllerTest < ActionController::TestCase
  setup do
    @instructor = users(:instructor)
    sign_in @instructor

    @scenario = scenarios(:one)
    @a_scenario_name = 'Scenario Name'
    @a_scenario_description = 'Scenario Description'
  end

  test 'should update scenario' do
    the_updated_name = 'Updated scenario name'

    put :update, :id => @scenario.id, :scenario => { :name =>  the_updated_name}
    assert_response :no_content

    updated_scenario = Scenario.find(@scenario.id)

    assert_equal updated_scenario.name, the_updated_name
  end

  test 'should fail to update a locked scenario' do
    put :update, :id => scenarios(:locked).id, :scenario => { :name => 'Poor unauthorized boy'}

    assert_response :bad_request
  end

  test 'should fail to update scenario with insufficent permissions' do
    sign_in(users(:student))

    put :update, :id => @scenario.id, :scenario => { :name => 'Poor unauthorized boy'}

    assert_response :unauthorized
  end

  test 'should only index unlocked scenarios belonging to instructor university' do
    sign_in(users(:instructor_sfu))
    get :index

    assert_response :ok

    expected_result = [scenarios(:two)]

    assert_equal serialize(expected_result, ScenarioSerializer, @instructor), response.body
  end

  test 'should fail to index scenarios when permissions are insufficient' do
    sign_in(users(:student))

    get :index

    assert_response :unauthorized
  end

  test 'should get scenario' do
    get :show, :id => @scenario.id

    assert_response :ok

    assert_equal serialize(@scenario, ScenarioSerializer, @instructor), response.body
  end

  test 'should fail to get scenario when permissions are insufficient' do
    sign_in(users(:student))

    get :show, :id => @scenario.id

    assert_response :unauthorized
  end

  test 'should fail to get scenario when it belongs to a different university' do
    get :show, :id => scenarios(:two).id # Belongs to SFU

    assert_response :unauthorized
  end

  test 'should create scenario' do
    assert_difference('Scenario.count') do
      post :create, scenario: { name: @a_scenario_name, description: @a_scenario_description }
    end

    assert_response :created

    @expected = Scenario.new(
      :name => @a_scenario_name,
      :description => @a_scenario_description,
      :archived => false
    )

    created_scenario = Scenario.find_by_name(@a_scenario_name)

    assert_scenarios_are_equal(@expected, created_scenario)
  end

  test 'should initialize root node when creating a scenario' do
    post :create, scenario: { name: @a_scenario_name }

    assert_response :created

    created_scenario = Scenario.find_by_name(@a_scenario_name)
    root_node = Node.find_by_scenario_id(created_scenario.id)

    assert_equal(created_scenario.root_node_id, root_node.id)
    assert_equal root_node.label, 1
    assert(root_node.is_start)
  end


  test 'should fail to create scenario when name already exists at same university' do
    post :create, scenario: { name: @scenario.name }

    assert_response :unprocessable_entity
  end

  test 'should fail to create scenario when name exists with different case' do
    post :create, scenario: { name: @scenario.name.upcase }

    assert_response :unprocessable_entity
  end

  test 'should still succeed when name exists at other university' do
    @instructor_sfu = users(:instructor_sfu)
    sign_in @instructor_sfu

    post :create, scenario: { name: @scenario.name }

    assert_response :success
  end

  test 'should fail to create a scenario when name is too short' do
    post :create, scenario: { name: "abc" }

    assert_response :unprocessable_entity
  end

  test 'should ignore archive and root node id params when they are provided' do
    a_root_node_id = 100

    assert_difference('Scenario.count') do
      post :create, scenario: { name: @a_scenario_name, description: @a_scenario_description, 
        archived: true, root_node_id: a_root_node_id }
    end

    assert_response :created

    @expected = Scenario.new(
      :name => @a_scenario_name,
      :description => @a_scenario_description,
      :archived => false
    )

    created_scenario = Scenario.find_by_name(@a_scenario_name)
    
    assert_scenarios_are_equal(@expected, created_scenario)
    assert_not_equal(a_root_node_id, created_scenario['root_node_id'])
  end

  test 'should fail to create scenario when permissions are insufficient' do
    sign_out @instructor
    student = users(:student)
    sign_in student

    post :create, scenario: { name: "name", description: "desc" }

    assert_response :unauthorized
  end

  test 'should set scenario copy name when it is provided' do
    the_scenario_name = 'Copied Scenario'
    post :copy, :id => @scenario.id, :scenario => {:name => the_scenario_name}

    assert_response :created

    scenario_copy = Scenario.order('created_at').last

    assert_equal scenario_copy[:name], the_scenario_name
    assert_equal scenario_copy[:description], @scenario[:description]
  end

  test 'should fail to copy scenario when setting name to an already existing one' do
    post :copy, :id => @scenario.id, :scenario => { :name => @scenario.name }

    assert_response :unprocessable_entity
  end

  test 'should not allow students to copy scenarios' do
    sign_out(@instructor)
    sign_in(users(:student))

    post :copy, :id => @scenario.id, :scenario => {}

    assert_response :unauthorized
  end

  test 'should not allow instructors at other universities to copy scenarios' do
    sign_out(@instructor)
    sign_in(users(:instructor_sfu))

    post :copy, :id => @scenario.id, :scenario => {}

    assert_response :unauthorized
  end

  test 'should copy scenario' do
    post :copy, :id => @scenario.id, :scenario => {:name => "Copied Name"}

    scenario_copy = Scenario.order('created_at').last

    assert_scenario_equivalence @scenario, scenario_copy
  end

  private
  def assert_scenarios_are_equal(expected, actual)
    assert_equal(expected[:name], actual['name'])
    assert_equal(expected[:description], actual['description'])
    assert_equal(expected[:archived], actual['archived'])
  end

  def assert_scenario_equivalence(original_scenario, copied_scenario)
    assert_equal copied_scenario[:description], original_scenario[:description]
    assert_node_equivalence(original_scenario.nodes, copied_scenario.nodes)
  end

  def assert_node_equivalence(original_nodes, copied_nodes)
    original_nodes.each do |original_node|
      assert copied_nodes.one? { |node_copy| equivalent_nodes?(node_copy, original_node) }
    end
  end

  def equivalent_nodes?(first, second)
    first[:title] == second[:title] and first[:body] == second[:body] and equivalent_choices?(first.choices, second.choices)
  end

  def equivalent_choices?(original_choices, copied_choices)
    original_choices.each do |original_choice|
      assert copied_choices.one? { |choice_copy| equivalent_choice?(choice_copy, original_choice) }
    end
  end

  def equivalent_choice?(first, second)
    first[:text] == second[:text]
  end
end
