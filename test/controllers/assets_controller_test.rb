require 'test_helper'

class AssetsControllerTest < ActionController::TestCase
  setup do
    @asset = assets(:one)

    @instructor = users(:instructor)
    sign_in @instructor
  end

  # TODO: Fix this
  # test 'should create asset' do
  #   the_image = fixture_file_upload 'firekirby.png'
  #
  #   assert_difference('Asset.count') do
  #     post :create, asset: {image: the_image}
  #   end
  #
  #   assert_response :created
  #
  #   created_asset = Asset.find_by_image_file_name('firekirby.png')
  #   expected_asset = Asset.new(:id => created_asset.id,
  #                              :image_file_name => 'firekirby.png')
  #
  #   assert_equal expected_asset, created_asset
  # end

  # test 'should create asset' do
  #   the_image_name = 'FlyPopRulez.jpg'
  #   the_image = { :image => { :image_file_name => the_image_name, :image_content_type => 'image/jpeg' } }
  #
  #   post :create, :asset => the_image
  #
  #   assert_response :created
  #
  #   the_created_asset = Asset.order('created_at').last
  #
  #   assert_equal the_image_name, the_created_asset.image_file_name
  # end
  #
  # test 'should fail to upload asset when file size greater than one megabyte' do
  #   the_asset = {:image => { :image_content_type => 'image/jpeg', :image_file_size => 2.megabytes } }
  #
  #   post :create, :asset => the_asset
  #
  #   assert_response :unprocessable_entity
  # end
  #
  # test 'should fail to upload asset when content type is not image' do
  #   the_asset = {:image => { :image_content_type => 'text/html' } }
  #
  #   post :create, :asset => the_asset
  #
  #   assert_response :unprocessable_entity
  # end

  test 'should not be able to create asset with insufficient permissions' do
    sign_out(@instructor)
    sign_in(users(:student))

    the_asset = { image: {:image_file_name =>'blah/blah'} }

    post :create, asset: the_asset

    assert_response :unauthorized
  end

  test 'should get all assets' do
    get :index

    assert_response :ok

    expected_assets = [assets(:two), assets(:one)]

    assert_equal serialize(expected_assets, AssetSerializer, @instructor), response.body
  end

  test 'should get asset' do
    get :show, :id => @asset.id

    assert_response :ok

    assert_equal serialize(@asset, AssetSerializer, @instructor), response.body
  end
end
