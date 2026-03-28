class ImsSubReport < ApplicationRecord
  belongs_to :ims_case

  validates :sub_type, presence: true
  validates :report_status, presence: true
end
