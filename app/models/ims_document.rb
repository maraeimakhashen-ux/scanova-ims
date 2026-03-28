class ImsDocument < ApplicationRecord
  belongs_to :ims_case
  has_one_attached :attachment_file

  validates :file_name, presence: true
  validates :file_type, presence: true
end
