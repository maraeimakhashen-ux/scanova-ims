class CreateImsReasonDisclaimers < ActiveRecord::Migration[8.1]
  def change
    create_table :ims_reason_disclaimers do |t|
      t.string :reason, null: false
      t.text :disclaimer, null: false
      t.timestamps
    end

    add_index :ims_reason_disclaimers, :reason, unique: true
  end
end
