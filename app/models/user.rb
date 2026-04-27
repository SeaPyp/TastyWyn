class User < ActiveRecord::Base
  has_secure_password
  has_many :posts
  has_many :wines, :through => :posts
  has_many :comments
  validates :email, uniqueness: true
  validates :password, presence: true,
                    length: { minimum: 5 }
end
