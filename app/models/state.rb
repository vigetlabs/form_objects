class State < ActiveRecord::Base
  validates :name, :abbreviation, presence: true
end
