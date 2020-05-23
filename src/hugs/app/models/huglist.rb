class Huglist < ApplicationRecord
    has_many :userhugs
    has_many :profiles, through: :userhugs
    validates :hugtype, presence: true
end
