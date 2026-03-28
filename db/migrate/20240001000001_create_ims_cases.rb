class CreateImsCases < ActiveRecord::Migration[8.1]
  def change
    create_table :ims_cases do |t|
      t.string :accession_number, null: false
      t.string :patient_identifier, null: false
      t.string :patient_name
      t.string :patient_age
      t.string :patient_gender
      t.string :specimen_type, null: false
      t.string :organ_site, null: false
      t.date :collection_date
      t.date :uploaded_date
      t.string :pathologist
      t.string :status, null: false, default: "active"
      t.string :specimen_origin
      t.string :specimen_size
      t.string :referral_doctor
      t.string :referral_clinic
      t.text :clinical_history
      t.text :gross_description
      t.text :microscopic_description
      t.text :diagnosis
      t.string :diagnosis_category
      t.string :report_status, default: "draft"
      t.text :notes
      t.datetime :corrected_at
      t.boolean :is_volunteer, null: false, default: false
      t.datetime :signed_at
      t.datetime :archive_read_at
      t.timestamps
    end

    add_index :ims_cases, :accession_number, unique: true
    add_index :ims_cases, :status
    add_index :ims_cases, :report_status
    add_index :ims_cases, :pathologist
  end
end
