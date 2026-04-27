class Post < ApplicationRecord
  belongs_to :user
  belongs_to :wine
  has_many :comments, dependent: :destroy
  has_one_attached :image

  validates :title, presence: true
  validates :text, presence: true
  validate :acceptable_image_content_type

  ALLOWED_IMAGE_TYPES = %w[image/jpeg image/png image/gif].freeze

  private

  def acceptable_image_content_type
    return unless image.attached?

    unless ALLOWED_IMAGE_TYPES.include?(image.content_type)
      errors.add(:image, "must be a JPEG, PNG, or GIF")
    end
  end
end
