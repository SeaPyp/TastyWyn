class Post < ApplicationRecord
  belongs_to :user
  belongs_to :wine, optional: true
  has_many :comments
  has_one_attached :image

  validates :title, presence: true
  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }, allow_nil: true
  validate :acceptable_image

  private

  def acceptable_image
    return unless image.attached?
    unless image.blob.content_type.in?(%w[image/jpeg image/png image/gif])
      errors.add(:image, 'must be a JPEG, PNG, or GIF')
    end
  end
end
