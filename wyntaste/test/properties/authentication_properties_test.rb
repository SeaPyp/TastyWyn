require "test_helper"

class AuthenticationPropertiesTest < ActionDispatch::IntegrationTest
  # Feature: rails-modernization, Property 3: Unauthenticated request redirect
  # **Validates: Requirements 3.5**
  #
  # For any controller action that requires authentication, when no valid
  # session exists, the application SHALL redirect to the login page.
  test "Property 3: unauthenticated request redirect" do
    # Protected GET routes that require authentication
    # Only test routes whose controllers exist already
    protected_paths = [
      users_path,
      wines_path
    ]

    property_of {
      Rantly { choose(*protected_paths) }
    }.check(100) { |path|
      # Reset session to ensure unauthenticated
      reset!

      get path
      assert_response :redirect,
        "Unauthenticated GET to #{path} should redirect"
      assert_redirected_to login_path,
        "Unauthenticated GET to #{path} should redirect to login"
    }
  end
end
