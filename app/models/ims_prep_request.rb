class ImsPrepRequest < ApplicationRecord
  belongs_to :ims_case

  validates :request_type, presence: true
  validates :status, presence: true
end
