require 'test_helper'

class LeaveRequestsControllerTest < ActionController::TestCase
  setup do
    @leave_request = leave_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:leave_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create leave_request" do
    assert_difference('LeaveRequest.count') do
      post :create, :leave_request => @leave_request.attributes
    end

    assert_redirected_to leave_request_path(assigns(:leave_request))
  end

  test "should show leave_request" do
    get :show, :id => @leave_request.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @leave_request.to_param
    assert_response :success
  end

  test "should update leave_request" do
    put :update, :id => @leave_request.to_param, :leave_request => @leave_request.attributes
    assert_redirected_to leave_request_path(assigns(:leave_request))
  end

  test "should destroy leave_request" do
    assert_difference('LeaveRequest.count', -1) do
      delete :destroy, :id => @leave_request.to_param
    end

    assert_redirected_to leave_requests_path
  end
end
