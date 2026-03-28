class CreateImsShareComments < ActiveRecord::Migration[8.1]
  def change
    create_table :ims_share_comments do |t|
      t.references :ims_share_link, null: false, foreign_key: { on_delete: :cascade }
      t.string :author_name, null: false
      t.text :content, null: false
      t.boolean :is_read, null: false, default: false
      t.timestamps
    end
  end
end
