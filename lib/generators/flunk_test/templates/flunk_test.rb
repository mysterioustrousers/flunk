require 'test_helper'

class <%= class_name %>Test < Flunk

  setup do
  end

  test "Test Title"
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



  flunk "Test Title", "Why it flunks" do
    path      "/resource/:id"
    method    :get
    status    :unauthorized
  end

end
