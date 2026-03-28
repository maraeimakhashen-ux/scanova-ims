class ImsSlide < ApplicationRecord
  belongs_to :ims_case
  belongs_to :ims_block, optional: true
  has_one_attached :slide_file
  has_one_attached :thumbnail

  validates :slide_code, presence: true
  validates :stain_type, presence: true
  validates :qc_status, presence: true
  validates :workflow_status, presence: true
end
