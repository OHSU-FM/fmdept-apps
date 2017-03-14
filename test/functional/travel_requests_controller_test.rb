require 'test_helper'

class TravelRequestsControllerTest < ActionController::TestCase
  setup do
    @travel_request = travel_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:travel_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create travel_request" do
    assert_difference('TravelRequest.count') do
      post :create, :travel_request => @travel_request.attributes
    end

    assert_redirected_to travel_request_path(assigns(:travel_request))
  end

  test "should show travel_request" do
    get :show, :id => @travel_request.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @travel_request.to_param
    assert_response :success
  end

  test "should update travel_request" do
    put :update, :id => @travel_request.to_param, :travel_request => @travel_request.attributes
    assert_redirected_to travel_request_path(assigns(:travel_request))
  end

  test "should destroy travel_request" do
    assert_difference('TravelRequest.count', -1) do
      delete :destroy, :id => @travel_request.to_param
    end

    assert_redirected_to travel_requests_path
  end
end
