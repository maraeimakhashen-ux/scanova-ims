class CreateImsShareLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :ims_share_links do |t|
      t.references :ims_case, null: false, foreign_key: { on_delete: :cascade }
      t.json :case_ids
      t.string :token, null: false
      t.string :password_hash, null: false
      t.datetime :expires_at, null: false
      t.string :created_by, null: false, default: "Dr. Reynolds"
      t.string :recipient_name
      t.string :recipient_email
      t.json :recipients
      t.boolean :include_slides, null: false, default: true
      t.boolean :include_gross_docs, null: false, default: true
      t.boolean :include_case_info, null: false, default: true
      t.boolean :include_report, null: false, default: false
      t.boolean :include_draft_report, null: false, default: false
      t.string :reason
      t.text :disclaimer
      t.text :notes
      t.boolean :is_draft, null: false, default: false
      t.boolean :is_active, null: false, default: true
      t.integer :view_count, null: false, default: 0
      t.timestamps
    end

    add_index :ims_share_links, :token, unique: true
  end
end
