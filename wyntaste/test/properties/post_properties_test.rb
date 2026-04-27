require "test_helper"

class PostPropertiesTest < ActiveSupport::TestCase
  # Feature: rails-modernization, Property 5: Image content type validation
  # **Validates: Requirements 6.7**
  #
  # For any content type string, the validation SHALL accept if and only if
  # it's image/jpeg, image/png, or image/gif.
  test "Property 5: image content type validation" do
    allowed_types = %w[image/jpeg image/png image/gif]
    rejected_types = %w[
      image/bmp image/webp image/svg+xml image/tiff
      application/pdf application/octet-stream
      text/plain text/html text/css
      video/mp4 audio/mpeg
    ]
    all_types = allowed_types + rejected_types

    property_of {
      Rantly { choose(*all_types) }
    }.check(100) { |content_type|
      # Clean up from previous iterations
      ActiveStorage::Attachment.delete_all
      ActiveStorage::Blob.delete_all
      Post.delete_all
      User.delete_all
      Wine.delete_all

      user = User.create!(
        first_name: "Test",
        last_name: "User",
        email: "test_#{SecureRandom.hex(4)}@example.com",
        password: "password123"
      )
      wine = Wine.create!(name: "Test Wine #{SecureRandom.hex(4)}")

      post = Post.new(title: "Test Post", text: "Test text", user: user, wine: wine)

      # Attach a blob with the given content type
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new("fake image data"),
        filename: "test.jpg",
        content_type: content_type
      )
      post.image.attach(blob)

      if allowed_types.include?(content_type)
        assert post.valid?,
          "Post with image content_type '#{content_type}' should be valid, errors: #{post.errors.full_messages}"
      else
        assert_not post.valid?,
          "Post with image content_type '#{content_type}' should be invalid"
        assert post.errors[:image].any?,
          "Post with image content_type '#{content_type}' should have image error"
      end
    }
  end
end
