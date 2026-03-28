class ImsCase < ApplicationRecord
  has_many :ims_blocks, dependent: :destroy
  has_many :ims_slides, dependent: :destroy
  has_many :ims_documents, dependent: :destroy
  has_many :ims_gross_images, dependent: :destroy
  has_many :ims_share_links, dependent: :destroy
  has_many :ims_report_shares, dependent: :destroy
  has_many :ims_prep_requests, dependent: :destroy
  has_many :ims_sub_reports, dependent: :destroy

  validates :accession_number, presence: true, uniqueness: true
  validates :patient_identifier, presence: true
  validates :specimen_type, presence: true
  validates :organ_site, presence: true
  validates :status, presence: true
end
