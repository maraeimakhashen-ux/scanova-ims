class CreateImsStaffMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :ims_staff_members do |t|
      t.string :name, null: false
      t.string :role, null: false, default: "Staff"
      t.string :initials
      t.boolean :is_active, null: false, default: true
      t.timestamps
    end
  end
end
