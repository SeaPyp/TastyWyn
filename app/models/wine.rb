class Wine < ActiveRecord::Base
  belongs_to :user
  has_many :posts
  has_many :users, :through => :posts

  validates :name, presence: true
  validates :varietal, presence: true
  validates :vintage, presence: true,
                      numericality: { only_integer: true, greater_than: 1800, less_than_or_equal_to: Date.today.year }
end
