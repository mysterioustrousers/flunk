require 'test_helper'
require 'flunk'

class BananasTest < Flunk

  setup do
  end

  # Write tests that should succeed to make sure the required functionality works.
  test "Banana", "Create" do
    desc      "Create a Banana"
    path      "bananas"
    method    :post
    status    :created
    body      banana: { weight: 2 }
    before {
      p "before was called"
    }
    after {
      p "after was called"
    }
  end


  # Write a test that SHOULD fail to ensure your application handles bad requests gracefully.
  # flunk "Banana", "Create", "Not found" do
  #   path      "/bananas/10000"
  #   method    :get
  #   status    :not_found
  # end

end
