# WARNING: This test account is for LOCAL DEVELOPMENT ONLY.
# It must be removed or disabled before deploying to production.

test_user = User.find_or_create_by!(email: "utest@wyntaste.dev") do |user|
  user.first_name = "UTest"
  user.last_name = "Account"
  user.password = "12345"
  user.password_confirmation = "12345"
end

puts "Test user created: #{test_user.email} (id: #{test_user.id})"
