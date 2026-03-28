class ImsShareComment < ApplicationRecord
  belongs_to :ims_share_link

  validates :author_name, presence: true
  validates :content, presence: true
end
