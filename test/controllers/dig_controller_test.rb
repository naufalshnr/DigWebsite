require "test_helper"

class DigControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dig_index_url
    assert_response :success
  end
end
