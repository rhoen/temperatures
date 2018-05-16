class Device < ActiveRecord::Base
  validates :name, uniqueness: true
  has_many :readings
end
