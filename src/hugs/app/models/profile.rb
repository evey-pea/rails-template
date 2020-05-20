class Profile < ApplicationRecord
  belongs_to :user
  has_many :blocklists, through: :user
end
