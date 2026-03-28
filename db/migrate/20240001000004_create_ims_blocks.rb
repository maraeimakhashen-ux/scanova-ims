class CreateImsBlocks < ActiveRecord::Migration[8.1]
  def change
    create_table :ims_blocks do |t|
      t.references :ims_case, null: false, foreign_key: { on_delete: :cascade }
      t.string :block_code, null: false
      t.string :specimen_part
      t.text :notes
      t.timestamps
    end

    add_index :ims_blocks, [:ims_case_id, :block_code]
  end
end
