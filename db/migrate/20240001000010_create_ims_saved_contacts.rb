class CreateImsSavedContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :ims_saved_contacts do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :institution
      t.string :specialty
      t.timestamps
    end
  end
end
