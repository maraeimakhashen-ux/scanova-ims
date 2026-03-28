class CreateModuleLicenses < ActiveRecord::Migration[8.1]
  def change
    create_table :module_licenses do |t|
      t.string  :tenant_id,    null: false
      t.string  :module_name,  null: false
      t.boolean :enabled,      null: false, default: false

      t.timestamps
    end

    add_index :module_licenses, [:tenant_id, :module_name], unique: true

    reversible do |dir|
      dir.up do
        MODULES = %w[lis order_collect ims share billing quality_qc template_forms ai].freeze
        MODULES.each do |mod|
          execute <<~SQL
            INSERT INTO module_licenses (tenant_id, module_name, enabled, created_at, updated_at)
            VALUES ('default', '#{mod}', false, NOW(), NOW())
            ON CONFLICT DO NOTHING;
          SQL
        end
      end
    end
  end
end
