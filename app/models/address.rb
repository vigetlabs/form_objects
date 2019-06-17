class Address < ActiveRecord::Base
  has_one :person
  belongs_to :state

  validates :street_1, :city, :state_id, :postal_code, presence: true
end
