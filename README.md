Flunk
=====

A gem for testing Ruby on Rails web APIs by simulating a client.


### Installation

In your Gemfile, add this line:

    gem "flunk"

### Description

We write mostly JSON APIs using Rails, not your traditional web app, so we wanted a better way to test our JSON APIs. This is flunk.

### Usage

In each test block you call a series of methods as necessary:

* `desc`: In the future, a documentation generator will be added and this will be used to determine if the test should be documented as an API method.
* `path`: The relative URL for the resource.
* `method`: :get, :post, :put or :delete
* `username`: For authentication using basic auth.
* `password`: For authentication using basic auth.
* `body`: The body of the request.
* `status`: This method actually acts like an assertion. It is what the status of the response SHOULD be. An error will be thrown if it doesn't match.
* `assertions`: A block of of assertions you call to verify the response was what it should have been.

Once you call `assertions`, the request is fired and a `result` method is available within the assertions block containing the response.

### Generator

To generate a flunk test:

    rails g flunk_test User

This will create an integration test: test/integration/users_test.rb

### Example

It's your typical rails integration test, but inherits from Flunk:

    class UsersTest < Flunk

      setup do
      	@user = FactoryGirl.create(:user)
      end

You write tests that SHOULD pass to test your app's basic functionality all works:

      test "User", "Create" do
        desc      "Creating a new Langwich user."
      	path			"signup"
      	method		:post
      	body			user: attrs = FactoryGirl.attributes_for(:user)
      	status		:created
        before {
          assert_equal 0, user.languages.count
        }
        after {
          assert_equal result[:name],       attrs[:name]
          assert_equal result[:username],   attrs[:username]
          assert_equal result[:email],      attrs[:email]
          assert_not_nil result[:api_token]
          user = User.find_by_api_token result[:api_token]
          assert_equal 1, user.languages.count
        }
      end

      test "User", "Log In With Email" do
      	path			"login"
      	method		:get
      	body			username: @user.email, password: @user.password
      	status		:ok
        after {
          assert_not_nil result[:api_token]
        }
      end

      test "User", "Read" do
        desc      "Read a users information."
        path      "account"
        method    :get
        username  @user.api_token
        status    :ok
      end


Then, write tests that SHOULDN'T pass to make sure your app rejects bad requests correctly/gracefully:


      flunk "User", "Create", "Missing username" do
        desc      "Attempting to create a user without a username."
        path      "signup"
        method    :post
        body      user: FactoryGirl.attributes_for(:user, username: nil)
        status    :unprocessable_entity
      end

      flunk "User", "Create", "Username already taken" do
        path      "signup"
        method    :post
        body      user: FactoryGirl.attributes_for(:user, username: @user.username)
        status    :unprocessable_entity
      end
    end


### Documentation Generation

Flunk can generate and organize a folder structure of Markdown files documenting your API calls while it tests.
If you provide the `desc` for a test, a Markdown file will be created with all the information about that particular
API endpoint. Finally, it will organize each Markdown file into a folder named for the resource it is acting upon.

By default, if it comes across a test with a "desc", it will place the docs in `$RAILS_ROOT/docs/flunk/`. You can
customize this by putting this into an initializer:

    if Rails.env.test?
      Flunk.config.doc_directory "docs/firehose-docs/api"
      Flunk.config.doc_base_url "https://api.firehoseapp.com"
    end

The config method on the Flunk class returns a global Flunk instance, so you can set any property on it to be used
as a default.

At Firehose, we have a few JSON-only apps that we use Flunk to test, so we have a submodule at `docs/firehose-docs` in
each app and each app has Flunk dump the docs into a folder for that app. The Firehose API app dumps into the subfolder
`api`. This allows us to easily have Flunk write our docs for us into a folder that is part of it's own public repo
that contains all our documentation for all of our apps.

Here's an example of the Firehose Github repo that is our API docs: https://github.com/mysterioustrousers/firehose-docs

### Testing

Flunk is included as a submodule in our project [button](https://github.com/mysterioustrousers/button.git) and
is used to test it. Please clone `button`, run `git submodule update --init --recursive` then `rake` to make
sure the tests are passing for you before you begin. Then, make your changes in the flunk submodule, commit them
and push them to your own fork and issue a pull request. Thanks!

