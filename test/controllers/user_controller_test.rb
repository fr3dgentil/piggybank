require 'test_helper'

class UserControllerTest < ActionController::TestCase
  test "should get login" do
    get :login
    assert_response :success
  end

  test "should get new_user" do
    get :new_user
    assert_response :success
  end

  test "should get forgot_password" do
    get :forgot_password
    assert_response :success
  end

end
