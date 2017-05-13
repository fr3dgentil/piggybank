require 'test_helper'

class AppControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new_transaction" do
    get :new_transaction
    assert_response :success
  end

  test "should get aloter_transaction" do
    get :aloter_transaction
    assert_response :success
  end

  test "should get delete_transaction" do
    get :delete_transaction
    assert_response :success
  end

  test "should get options" do
    get :options
    assert_response :success
  end

end
