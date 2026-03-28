class CreateImsNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :ims_notifications do |t|
      t.string :ntype, null: false
      t.string :title, null: false
      t.text :message, null: false
      t.string :source
      t.integer :source_id
      t.boolean :is_read, null: false, default: false
      t.timestamps
    end
  end
end
