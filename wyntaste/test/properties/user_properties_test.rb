require "test_helper"

class UserPropertiesTest < ActiveSupport::TestCase
  # Feature: rails-modernization, Property 1: Case-insensitive email uniqueness
  # **Validates: Requirements 2.3**
  #
  # For any two User registration attempts where the email addresses differ
  # only in letter casing, the second registration SHALL be rejected and the
  # first User record SHALL remain unchanged.
  test "Property 1: case-insensitive email uniqueness" do
    property_of {
      base_email = "user_#{Rantly { sized(8) { string(:alpha).downcase } }}@example.com"
      variant = base_email.chars.map { |c|
        c.match?(/[a-z]/) && Rantly { boolean } ? c.upcase : c
      }.join
      [base_email, variant]
    }.check(100) { |base_email, variant_email|
      User.where("LOWER(email) = ?", base_email.downcase).delete_all

      first_user = User.create!(
        first_name: "First",
        last_name: "User",
        email: base_email,
        password: "validpass",
        password_confirmation: "validpass"
      )

      second_user = User.new(
        first_name: "Second",
        last_name: "User",
        email: variant_email,
        password: "validpass",
        password_confirmation: "validpass"
      )

      assert_not second_user.valid?,
        "User with email '#{variant_email}' should be invalid when '#{base_email}' exists"
      assert_includes second_user.errors[:email], "has already been taken"

      first_user.reload
      assert_equal base_email.downcase, first_user.email
      User.where(id: first_user.id).delete_all
    }
  end

  # Feature: rails-modernization, Property 2: Password minimum length enforcement
  # **Validates: Requirements 2.4**
  test "Property 2: password minimum length enforcement" do
    property_of {
      short_len = Rantly { range(1, 4) }
      short_pass = Rantly { sized(short_len) { string(:alpha) } }
      long_len = Rantly { range(5, 30) }
      long_pass = Rantly { sized(long_len) { string(:alpha) } }
      [short_pass, long_pass]
    }.check(100) { |short_pass, long_pass|
      short_user = User.new(
        first_name: "Test", last_name: "User",
        email: "short_#{SecureRandom.hex(4)}@example.com",
        password: short_pass, password_confirmation: short_pass
      )
      assert_not short_user.valid?,
        "Password '#{short_pass}' (length #{short_pass.length}) should be rejected"
      assert short_user.errors[:password].any?,
        "Should have password error for '#{short_pass}'"

      long_user = User.new(
        first_name: "Test", last_name: "User",
        email: "long_#{SecureRandom.hex(4)}@example.com",
        password: long_pass, password_confirmation: long_pass
      )
      long_user.valid?
      assert_empty long_user.errors[:password],
        "Password '#{long_pass}' (length #{long_pass.length}) should pass length validation"
    }
  end

  # Feature: rails-modernization, Property 8: Multiple validation errors preservation
  # **Validates: Requirements 10.1**
  test "Property 8: multiple validation errors preservation" do
    property_of {
      pass_len = Rantly { range(0, 4) }
      pass_len > 0 ? Rantly { sized(pass_len) { string(:alpha) } } : ""
    }.check(100) { |short_pass|
      user = User.new(
        first_name: "", last_name: "", email: "",
        password: short_pass, password_confirmation: short_pass
      )

      assert_not user.valid?

      error_attributes = user.errors.attribute_names
      assert_includes error_attributes, :first_name
      assert_includes error_attributes, :last_name
      assert_includes error_attributes, :email

      if short_pass.length < 5
        assert_includes error_attributes, :password
      end

      # Each attribute with errors should have at least one message
      error_attributes.each do |attr|
        assert user.errors[attr].length >= 1,
          "Attribute #{attr} should have at least one error message"
      end

      # No messages should overwrite each other
      assert user.errors.count >= error_attributes.length,
        "Total errors (#{user.errors.count}) >= attributes with errors (#{error_attributes.length})"
    }
  end
end
