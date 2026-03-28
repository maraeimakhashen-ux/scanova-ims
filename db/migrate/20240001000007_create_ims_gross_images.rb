class CreateImsGrossImages < ActiveRecord::Migration[8.1]
  def change
    create_table :ims_gross_images do |t|
      t.references :ims_case, null: false, foreign_key: { on_delete: :cascade }
      t.integer :block_id
      t.string :file_name, null: false
      t.string :file_path, null: false
      t.string :thumbnail_path
      t.integer :file_size, null: false, default: 0
      t.string :mime_type
      t.text :caption
      t.integer :sort_order, null: false, default: 0
      t.datetime :upload_date
      t.timestamps
    end
  end
end
