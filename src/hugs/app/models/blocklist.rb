class Blocklist < ApplicationRecord
  belongs_to :user
  belongs_to :blocked, class_name: "User", foreign_key: "blocked_id"

  validates_uniqueness_of :user, scope: :blocked_id

  scope :between, ->(user_id, blocked_id) do
      where("(blocklist.user_id = ? AND blocklist.blocked_id = ?) OR (blocklist.blocked_id = ? AND blocklist.user_id = ?)", user_id, blocked_id, user_id, blocked_id)
    end

  
end
