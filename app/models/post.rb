class Post < ApplicationRecord
  belongs_to :user
  
  validates :title, presence: true
  validates :content, length: { minimum: 10 }
  
  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }
  
  def summary
    content&.truncate(100)
  end
end 