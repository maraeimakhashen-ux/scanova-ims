class CreateImsSubReports < ActiveRecord::Migration[8.1]
  def change
    create_table :ims_sub_reports do |t|
      t.references :ims_case, null: false, foreign_key: true
      t.string :sub_type, null: false
      t.text :clinical_history
      t.text :gross_description
      t.text :microscopic_description
      t.text :diagnosis
      t.text :notes
      t.string :pathologist
      t.string :report_status, null: false, default: "draft"
      t.datetime :verified_at
      t.timestamps
    end
  end
end
