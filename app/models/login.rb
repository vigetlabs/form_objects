class Login < ActiveRecord::Base
  belongs_to :person

  validates :email, presence: true
  has_secure_password
end
