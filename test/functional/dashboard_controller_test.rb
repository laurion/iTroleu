require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  test "should get start" do
    get :start
    assert_response :success
  end

  test "should get end" do
    get :end
    assert_response :success
  end

  test "should get search" do
    get :search
    assert_response :success
  end

end
