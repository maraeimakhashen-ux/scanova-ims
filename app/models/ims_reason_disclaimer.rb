class ImsReasonDisclaimer < ApplicationRecord
  validates :reason, presence: true, uniqueness: true
  validates :disclaimer, presence: true
end
