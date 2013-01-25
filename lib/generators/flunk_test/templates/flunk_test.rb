require 'test_helper'

class <%= class_name.pluralize %>Test < Flunk

  setup do
  end

  # Write tests that should succeed to make sure the required functionality works.
  test "Resource", "Action" do
    desc      "A description of the function this tests"
    path      "resource/:id"
    method    :get
    username  @user.username
    password  @user.password
    status    :ok
    assertions {
      assert_equal 2, 2
    }
  end


  # Write a test that SHOULD fail to ensure your application handles bad requests gracefully.
  flunk "Resource", "Action, "Why it flunks" do
    path      "/resource/:id"
    method    :get
    status    :unauthorized
  end

end
