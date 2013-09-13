require 'test_helper'
require 'flunk'

class BananasTest < Flunk

  doc_file ""


  # Write tests that should succeed to make sure the required functionality works.
  test "Banana", "Create" do
    before {
      @count = 1
      p "before was called"
    }
    desc      "Create a Banana"
    path      "bananas"
    method    :post
    status    :created
    body      banana: { weight: 2 }
    after {
      assert_equal @count, 1
      p "after was called"
    }
  end

  test "Banana Two", "Create" do
    desc      "Create a Banana"
    path      "bananas"
    method    :post
    status    :created
    body      banana: { weight: 2 }
  end

  # Write a test that SHOULD fail to ensure your application handles bad requests gracefully.
  flunk "Banana", "Create", "Not found" do
    path      "bananas/1000"
    method    :get
    status    :not_found
  end

end
