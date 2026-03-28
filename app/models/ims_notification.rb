class ImsNotification < ApplicationRecord
  validates :ntype, presence: true
  validates :title, presence: true
  validates :message, presence: true
end
