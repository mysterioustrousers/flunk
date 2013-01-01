Flunk
=====

A gem for testing a Ruby on Rails web APIs by simulating a client.


### Installation

In your Gemfile, add this line:

    gem "flunk"

### Description

We write mostly JSON APIs using Rails, not your traditional web app, so we wanted a better way to test our JSON APIs. This is flunk.

### Usage

In each test block you call a series of methods [`desc`, `path`, `method`, `username`, `password`, `body`, `status`, `assertions`] as necessary.

`desc`: In the future, a documentation generator will be added and this will be used to determine if the test should be documented as an API method.
`path`: The relative URL for the resource.
`method`: :get, :post, :put or :delete
`username`: For authentication using basic auth.
`password`: For authentication using basic auth.
`body`: The body of the request.
`status`: This method actually acts like an assertion. It is what the status of the response SHOULD be. An error will be thrown if it doesn't match.
`assertions`: A block of of assertions you call to verify the response was what it should have been.

Once you call `assertions`, the request is fired and a `result` method is available within the assertions block containing the response.

### Example

It's your typical rails integration test, but inherits from Flunk:

    class UsersTest < Flunk
    
      setup do
      	@user = FactoryGirl.create(:user)
      end

You write tests that SHOULD pass to test your app's basic functionality all works:

      test "Create User" do
        desc      "Creating a new Langwich user."
      	path			"signup"
      	method		:post
      	body			user: attrs = FactoryGirl.attributes_for(:user)
      	status		:created
        assertions {
          assert_equal result[:name],       attrs[:name]
          assert_equal result[:username],   attrs[:username]
          assert_equal result[:email],      attrs[:email]
          assert_not_nil result[:api_token]
          user = User.find_by_api_token result[:api_token]
          assert_equal 1, user.languages.count
        }
      end
      
      test "Log In" do
        desc      "Obtain a users API token by logging in with their username and password"
      	path			"login"
      	method		:get
      	body			username: @user.username, password: @user.password
      	status		:ok
        assertions {
          assert_not_nil result[:api_token]
        }
      end
      
      test "Log In With Email" do
      	path			"login"
      	method		:get
      	body			username: @user.email, password: @user.password
      	status		:ok
        assertions {
          assert_not_nil result[:api_token]
        }
      end
      
      test "Read User" do
        desc      "Read a users information."
        path      "account"
        method    :get
        username  @user.api_token
        status    :ok
      end
      
      test "Update User" do
        desc      "Update the username, e-mail, password and/or name"
        path      "account"
        method    :put
        username  @user.api_token
        body      user: { username: username = Faker::Internet.user_name }
        status    :ok
        assertions {
          assert_equal result[:username], username
        }
      end
      
      test "Update E-mail" do
        path      "account"
        method    :put
        username  @user.api_token
        body      user:  { email: email = Faker::Internet.email }
        status    :ok
        assertions {
          assert_equal result[:email], email
        }
      end
      
      test "Update User Password" do
        path      "account"
        method    :put
        username  @user.api_token
        body      user: { password: Faker::Lorem.characters(10) }
        status    :ok
      end
      
      test "Update Name" do
        path      "account"
        method    :put
        username  @user.api_token
        body      user: { name: name = Faker::Name.first_name }
        status    :ok
        assertions {
          assert_equal result[:name], name
        }
      end
      
      test "Delete User" do
        path      "account"
        method    :delete
        username  @user.api_token
        status    :ok
      end
      


Then, write tests that SHOULDN'T pass to make sure your app rejects bad requests correctly/gracefully:

      
      flunk "Create User", "Missing username" do
        desc      "Attempting to create a user without a username."
        path      "signup"
        method    :post
        body      user: FactoryGirl.attributes_for(:user, username: nil)
        status    :unprocessable_entity
      end
      
      flunk "Create User", "Username already taken" do
        path      "signup"
        method    :post
        body      user: FactoryGirl.attributes_for(:user, username: @user.username)
        status    :unprocessable_entity
      end
      
      flunk "Create User", "Invalid username" do
        path      "signup"
        method    :post
        body      user: FactoryGirl.attributes_for(:user, username: "a234$2aa" )
        status    :unprocessable_entity
      end
      
      flunk "Create User", "Missing e-mail" do
        desc      "Attempting to create a user without a e-mail."
        path      "signup"
        method    :post
        body      user: FactoryGirl.attributes_for(:user, email: nil)
        status    :unprocessable_entity
      end
      
      flunk "Create User", "E-mail already taken" do
        desc      "Attempting to create a user with an e-mail that's already taken."
        path      "signup"
        method    :post
        body      user: FactoryGirl.attributes_for(:user, email: @user.email)
        status    :unprocessable_entity
      end
      
      flunk "Create User", "Invalid e-mail" do
        path      "signup"
        method    :post
        body      user: FactoryGirl.attributes_for(:user, email: "aaaa@aakk")
        status    :unprocessable_entity
      end
      
      flunk "Create User", "Missing password" do
        desc      "Attempting to create a user without a password."
        path      "signup"
        method    :post
        body      user: FactoryGirl.attributes_for(:user, password: nil)
        status    :unprocessable_entity
      end
      
      flunk "Create User", "Missing name" do
        path      "signup"
        method    :post
        body      user: FactoryGirl.attributes_for(:user, name: nil)
        status    :unprocessable_entity
      end
      
      
      
      
      flunk "Log In", "No username" do
        desc       "Attempting to obtain an API token with the wrong password"
        path       "login"
        method     :get
        body       password: "a"
        status     :unauthorized
      end
      
      flunk "Log In", "Wrong password" do
        desc       "Attempting to obtain an API token with the wrong password"
        path       "login"
        method     :get
        body       username: @user.username, password: "a"
        status     :unauthorized
      end
      
      
      
      
      flunk "Read User", "Wrong API token" do
        path       "login"
        method     :get
        username   "a"
        status     :unauthorized
      end
      
      
      
      
      flunk "Update User", "Wrong password" do
        path      "account"
        method    :put
        username  "a"
        body      user: FactoryGirl.attributes_for(:user)
        status    :unauthorized
      end
      
      flunk "Update User", "Username already taken" do
        path      "account"
        method    :put
        username  @user.api_token
        u = FactoryGirl.create(:user)
        body      user: { username: u.username }
        status    :unprocessable_entity
      end
      
       flunk "Update User", "Invalid username" do
        path      "account"
        method    :put
        username  @user.api_token
        body      user: { username: "a234$2aa" }
        status    :unprocessable_entity
      end
      
      flunk "Update User", "E-mail already taken" do
        desc      "Attempting to update a user with an e-mail that's already taken."
        path      "account"
        method    :put
        username  @user.api_token
        u = FactoryGirl.create(:user)
        body      user: { email: u.email }
        status    :unprocessable_entity
      end
      
      flunk "Update User", "Invalid e-mail" do
        desc      "Attempting to update the user with an invalid e-mail"
        path      "account"
        method    :put
        username  @user.api_token
        body      user: { email: "aaaa@aakk" }
        status    :unprocessable_entity
      end
      
        
      
      
      flunk "Delete User", "Wrong password" do
        path      "account"
        method    :delete
        username  "a"
        body      user: FactoryGirl.attributes_for(:user)
        status    :unauthorized
      end
      
    end

### Generator

To generate a flunk test:

    rails g generate flunk_test User

This will create an integration test: test/integration/users_test.rb
