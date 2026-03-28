class ImsGrossImage < ApplicationRecord
  belongs_to :ims_case
  has_one_attached :image_file

  validates :file_name, presence: true
end
