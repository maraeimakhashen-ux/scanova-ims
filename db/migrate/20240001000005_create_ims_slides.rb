class CreateImsSlides < ActiveRecord::Migration[8.1]
  def change
    create_table :ims_slides do |t|
      t.references :ims_case, null: false, foreign_key: { on_delete: :cascade }
      t.references :ims_block, foreign_key: { on_delete: :nullify }
      t.string :slide_code, null: false
      t.string :full_label_text
      t.string :stain_type, null: false, default: "H&E"
      t.string :antibody_marker
      t.integer :level_number
      t.boolean :recut_flag, null: false, default: false
      t.string :scanner_name
      t.date :scan_date
      t.datetime :upload_date
      t.string :file_name
      t.string :file_path
      t.string :thumbnail_path
      t.string :label_image_path
      t.string :barcode
      t.string :magnification
      t.string :dimensions
      t.integer :file_size
      t.string :qc_status, null: false, default: "pending"
      t.string :workflow_status, null: false, default: "uploaded"
      t.string :viewer_url
      t.integer :rack_row
      t.integer :rack_position
      t.integer :sort_order, null: false, default: 0
      t.string :tags, array: true, default: []
      t.text :notes
      t.timestamps
    end

    add_index :ims_slides, :qc_status
    add_index :ims_slides, :workflow_status
    add_index :ims_slides, :stain_type
  end
end
