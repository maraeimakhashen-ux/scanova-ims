class CreateImsSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :ims_settings do |t|
      t.string :key, null: false
      t.text :value, null: false
      t.timestamps
    end

    add_index :ims_settings, :key, unique: true
  end
end
