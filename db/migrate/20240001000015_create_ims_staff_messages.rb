class CreateImsStaffMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :ims_staff_messages do |t|
      t.string :sender_name, null: false, default: "Dr. Reynolds"
      t.string :recipient_name, null: false
      t.string :subject
      t.text :content, null: false
      t.boolean :is_read, null: false, default: false
      t.timestamps
    end
  end
end
