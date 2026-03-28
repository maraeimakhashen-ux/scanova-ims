class ImsShareLink < ApplicationRecord
  belongs_to :ims_case
  has_many :ims_share_comments, dependent: :destroy

  validates :token, presence: true, uniqueness: true
  validates :password_hash, presence: true
  validates :expires_at, presence: true
end
