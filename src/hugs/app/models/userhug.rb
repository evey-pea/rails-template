class Userhug < ApplicationRecord
    belongs_to :profile, dependent: :destroy
    belongs_to :huglist, dependent: :destroy
end
