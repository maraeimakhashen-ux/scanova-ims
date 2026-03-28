class ImsReportShare < ApplicationRecord
  belongs_to :ims_case

  validates :recipient_type, presence: true
  validates :recipient_name, presence: true
  validates :channel, presence: true
end
