class Profile < ApplicationRecord
  belongs_to :user
  has_many :blocklists, through: :user
  has_one_attached :picture
  has_many :userhugs
  has_many :huglists, through: :userhugs
  accepts_nested_attributes_for :huglists, allow_destroy: true
  geocoded_by :address

  after_validation :geocode
  
  validates :name_display, :name_first, :name_second, :road, :suburb, :state, :postcode, presence: true

  def address
    [road, suburb, city, postcode, state, country].compact.join(", ")
  end
  
end
