class ImsStaffMessage < ApplicationRecord
  validates :sender_name, presence: true
  validates :recipient_name, presence: true
  validates :content, presence: true
end
