class User < ApplicationRecord
  has_secure_password
  has_many :posts
  has_many :wines, :through => :posts
  has_many :comments
  has_many :owned_wines, class_name: 'Wine', foreign_key: 'user_id'
  validates :email, uniqueness: true
  validates :password, presence: true,
                    length: { minimum: 5 }
end
