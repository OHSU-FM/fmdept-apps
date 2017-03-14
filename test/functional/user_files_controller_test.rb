require 'test_helper'

class UserFilesControllerTest < ActionController::TestCase
  setup do
    @user_file = user_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_file" do
    assert_difference('UserFile.count') do
      post :create, :user_file => @user_file.attributes
    end

    assert_redirected_to user_file_path(assigns(:user_file))
  end

  test "should show user_file" do
    get :show, :id => @user_file.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @user_file.to_param
    assert_response :success
  end

  test "should update user_file" do
    put :update, :id => @user_file.to_param, :user_file => @user_file.attributes
    assert_redirected_to user_file_path(assigns(:user_file))
  end

  test "should destroy user_file" do
    assert_difference('UserFile.count', -1) do
      delete :destroy, :id => @user_file.to_param
    end

    assert_redirected_to user_files_path
  end
end
