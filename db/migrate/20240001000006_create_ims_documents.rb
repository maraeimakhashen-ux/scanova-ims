class CreateImsDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :ims_documents do |t|
      t.references :ims_case, null: false, foreign_key: { on_delete: :cascade }
      t.string :file_name, null: false
      t.string :file_path, null: false
      t.integer :file_size, null: false, default: 0
      t.string :file_type, null: false
      t.string :mime_type
      t.string :category, null: false, default: "general"
      t.text :description
      t.datetime :upload_date
      t.timestamps
    end
  end
end
