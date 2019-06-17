class Person < ActiveRecord::Base
  has_one :login
  has_one :address

  validates :first_name, :last_name, presence: true

  def name
    [first_name, last_name].join(" ")
  end
end
