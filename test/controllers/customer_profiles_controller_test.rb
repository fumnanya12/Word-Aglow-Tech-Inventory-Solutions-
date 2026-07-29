require "test_helper"

class CustomerProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get customer_profiles_show_url
    assert_response :success
  end

  test "should get edit" do
    get customer_profiles_edit_url
    assert_response :success
  end
end
