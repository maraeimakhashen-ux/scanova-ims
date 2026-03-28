class ImsBlock < ApplicationRecord
  belongs_to :ims_case
  has_many :ims_slides, dependent: :destroy

  validates :block_code, presence: true
end
