require 'test_helper'

module ManybotsGmail
  class EmailsControllerTest < ActionController::TestCase
    test "should get show" do
      get :show
      assert_response :success
    end
  
  end
end
