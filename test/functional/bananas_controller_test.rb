require 'test_helper'

class BananasControllerTest < ActionController::TestCase
  setup do
    @banana = bananas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bananas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create banana" do
    assert_difference('Banana.count') do
      post :create, banana: { color: @banana.color, size: @banana.size, weight: @banana.weight }
    end

    assert_redirected_to banana_path(assigns(:banana))
  end

  test "should show banana" do
    get :show, id: @banana
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @banana
    assert_response :success
  end

  test "should update banana" do
    put :update, id: @banana, banana: { color: @banana.color, size: @banana.size, weight: @banana.weight }
    assert_redirected_to banana_path(assigns(:banana))
  end

  test "should destroy banana" do
    assert_difference('Banana.count', -1) do
      delete :destroy, id: @banana
    end

    assert_redirected_to bananas_path
  end
end
