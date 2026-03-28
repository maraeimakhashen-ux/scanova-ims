class ModuleLicense < ApplicationRecord
  MODULES = %w[lis order_collect ims share billing quality_qc template_forms ai].freeze

  validates :tenant_id,   presence: true
  validates :module_name, presence: true, inclusion: { in: MODULES }
  validates :module_name, uniqueness: { scope: :tenant_id }

  def self.licensed?(tenant_id, module_name)
    where(tenant_id: tenant_id.to_s, module_name: module_name.to_s, enabled: true).exists?
  end
end
