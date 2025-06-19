class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  
  validates :name, presence: true, if: :name_required?
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, unless: :guest_user?
  validates :age, numericality: { greater_than: 0 }, on: :create
  
  scope :active, -> { where(active: true) }
  scope :sorted_by_name, -> { order(:name) }
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def calculate_age_next_year
    Date.current.year - birth_date.year + 1
  end
  
  private
  
  def name_required?
    !guest_user?
  end
  
  def guest_user?
    user_type == 'guest'
  end
end 