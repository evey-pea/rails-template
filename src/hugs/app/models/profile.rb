class Profile < ApplicationRecord
  belongs_to :user
  has_many :blocklists, through: :user
  geocoded_by :address
  after_validation :geocode
  has_one_attached :picture
  
  validates :name_display, :name_first, :name_second, :road, :suburb, :state, :postcode, presence: true

  def address
    [road, suburb, city, postcode, state, country].compact.join(", ")
  end
  
end
