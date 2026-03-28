class CreateImsReportShares < ActiveRecord::Migration[8.1]
  def change
    create_table :ims_report_shares do |t|
      t.references :ims_case, null: false, foreign_key: { on_delete: :cascade }
      t.string :recipient_type, null: false
      t.string :recipient_name, null: false
      t.string :recipient_phone
      t.string :recipient_email
      t.string :channel, null: false
      t.text :message
      t.string :shared_by
      t.timestamps
    end
  end
end
