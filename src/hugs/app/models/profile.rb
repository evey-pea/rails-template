class Profile < ApplicationRecord
  belongs_to :user
  has_many :blocklists, through: :user
  
  geocoded_by :address
  after_validation :geocode
  
  def address
    [road, suburb, city, postcode, state, country].compact.join(", ")
  end
  
end
