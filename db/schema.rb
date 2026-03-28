# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_27_220000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "blocks", id: :serial, force: :cascade do |t|
    t.text "block_code", null: false
    t.integer "case_id", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "notes"
    t.text "specimen_part"
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
  end

  create_table "cases", id: :serial, force: :cascade do |t|
    t.text "accession_number", null: false
    t.timestamptz "archive_read_at"
    t.text "clinical_history"
    t.date "collection_date"
    t.timestamptz "corrected_at"
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "diagnosis"
    t.text "diagnosis_category"
    t.text "gross_description"
    t.boolean "is_volunteer", default: false, null: false
    t.text "microscopic_description"
    t.text "notes"
    t.text "organ_site", null: false
    t.text "pathologist"
    t.text "patient_age"
    t.text "patient_gender"
    t.text "patient_identifier", null: false
    t.text "patient_name"
    t.text "referral_clinic"
    t.text "referral_doctor"
    t.text "report_status", default: "draft"
    t.timestamptz "signed_at"
    t.text "specimen_origin"
    t.text "specimen_size"
    t.text "specimen_type", null: false
    t.text "status", default: "active", null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.date "uploaded_date"

    t.unique_constraint ["accession_number"], name: "cases_accession_number_unique"
  end

  create_table "documents", id: :serial, force: :cascade do |t|
    t.integer "case_id", null: false
    t.text "category", default: "general", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "description"
    t.text "file_name", null: false
    t.text "file_path", null: false
    t.integer "file_size", default: 0, null: false
    t.text "file_type", null: false
    t.text "mime_type"
    t.timestamptz "upload_date", default: -> { "now()" }, null: false
  end

  create_table "gross_images", id: :serial, force: :cascade do |t|
    t.integer "block_id"
    t.text "caption"
    t.integer "case_id", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "file_name", null: false
    t.text "file_path", null: false
    t.integer "file_size", default: 0, null: false
    t.text "mime_type"
    t.integer "sort_order", default: 0, null: false
    t.text "thumbnail_path"
    t.timestamptz "upload_date", default: -> { "now()" }, null: false
  end

  create_table "ims_blocks", force: :cascade do |t|
    t.string "block_code", null: false
    t.datetime "created_at", null: false
    t.bigint "ims_case_id", null: false
    t.text "notes"
    t.string "specimen_part"
    t.datetime "updated_at", null: false
    t.index ["ims_case_id", "block_code"], name: "index_ims_blocks_on_ims_case_id_and_block_code"
    t.index ["ims_case_id"], name: "index_ims_blocks_on_ims_case_id"
  end

  create_table "ims_cases", force: :cascade do |t|
    t.string "accession_number", null: false
    t.datetime "archive_read_at"
    t.text "clinical_history"
    t.date "collection_date"
    t.datetime "corrected_at"
    t.datetime "created_at", null: false
    t.text "diagnosis"
    t.string "diagnosis_category"
    t.text "gross_description"
    t.boolean "is_volunteer", default: false, null: false
    t.text "microscopic_description"
    t.text "notes"
    t.string "organ_site", null: false
    t.string "pathologist"
    t.string "patient_age"
    t.string "patient_gender"
    t.string "patient_identifier", null: false
    t.string "patient_name"
    t.string "referral_clinic"
    t.string "referral_doctor"
    t.string "report_status", default: "draft"
    t.datetime "signed_at"
    t.string "specimen_origin"
    t.string "specimen_size"
    t.string "specimen_type", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.date "uploaded_date"
    t.index ["accession_number"], name: "index_ims_cases_on_accession_number", unique: true
    t.index ["pathologist"], name: "index_ims_cases_on_pathologist"
    t.index ["report_status"], name: "index_ims_cases_on_report_status"
    t.index ["status"], name: "index_ims_cases_on_status"
  end

  create_table "ims_documents", force: :cascade do |t|
    t.string "category", default: "general", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "file_name", null: false
    t.string "file_path", null: false
    t.integer "file_size", default: 0, null: false
    t.string "file_type", null: false
    t.bigint "ims_case_id", null: false
    t.string "mime_type"
    t.datetime "updated_at", null: false
    t.datetime "upload_date"
    t.index ["ims_case_id"], name: "index_ims_documents_on_ims_case_id"
  end

  create_table "ims_gross_images", force: :cascade do |t|
    t.integer "block_id"
    t.text "caption"
    t.datetime "created_at", null: false
    t.string "file_name", null: false
    t.string "file_path", null: false
    t.integer "file_size", default: 0, null: false
    t.bigint "ims_case_id", null: false
    t.string "mime_type"
    t.integer "sort_order", default: 0, null: false
    t.string "thumbnail_path"
    t.datetime "updated_at", null: false
    t.datetime "upload_date"
    t.index ["ims_case_id"], name: "index_ims_gross_images_on_ims_case_id"
  end

  create_table "ims_notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_read", default: false, null: false
    t.text "message", null: false
    t.string "ntype", null: false
    t.string "source"
    t.integer "source_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ims_prep_requests", force: :cascade do |t|
    t.integer "block_id"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.bigint "ims_case_id", null: false
    t.integer "levels"
    t.string "marker_or_stain"
    t.text "notes"
    t.string "request_type", null: false
    t.string "requested_by"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["ims_case_id"], name: "index_ims_prep_requests_on_ims_case_id"
    t.index ["status"], name: "index_ims_prep_requests_on_status"
  end

  create_table "ims_reason_disclaimers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "disclaimer", null: false
    t.string "reason", null: false
    t.datetime "updated_at", null: false
    t.index ["reason"], name: "index_ims_reason_disclaimers_on_reason", unique: true
  end

  create_table "ims_report_shares", force: :cascade do |t|
    t.string "channel", null: false
    t.datetime "created_at", null: false
    t.bigint "ims_case_id", null: false
    t.text "message"
    t.string "recipient_email"
    t.string "recipient_name", null: false
    t.string "recipient_phone"
    t.string "recipient_type", null: false
    t.string "shared_by"
    t.datetime "updated_at", null: false
    t.index ["ims_case_id"], name: "index_ims_report_shares_on_ims_case_id"
  end

  create_table "ims_saved_contacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "institution"
    t.string "name", null: false
    t.string "specialty"
    t.datetime "updated_at", null: false
  end

  create_table "ims_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.text "value", null: false
    t.index ["key"], name: "index_ims_settings_on_key", unique: true
  end

  create_table "ims_share_comments", force: :cascade do |t|
    t.string "author_name", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.bigint "ims_share_link_id", null: false
    t.boolean "is_read", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["ims_share_link_id"], name: "index_ims_share_comments_on_ims_share_link_id"
  end

  create_table "ims_share_links", force: :cascade do |t|
    t.json "case_ids"
    t.datetime "created_at", null: false
    t.string "created_by", default: "Dr. Reynolds", null: false
    t.text "disclaimer"
    t.datetime "expires_at", null: false
    t.bigint "ims_case_id", null: false
    t.boolean "include_case_info", default: true, null: false
    t.boolean "include_draft_report", default: false, null: false
    t.boolean "include_gross_docs", default: true, null: false
    t.boolean "include_report", default: false, null: false
    t.boolean "include_slides", default: true, null: false
    t.boolean "is_active", default: true, null: false
    t.boolean "is_draft", default: false, null: false
    t.text "notes"
    t.string "password_hash", null: false
    t.string "reason"
    t.string "recipient_email"
    t.string "recipient_name"
    t.json "recipients"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.integer "view_count", default: 0, null: false
    t.index ["ims_case_id"], name: "index_ims_share_links_on_ims_case_id"
    t.index ["token"], name: "index_ims_share_links_on_token", unique: true
  end

  create_table "ims_slides", force: :cascade do |t|
    t.string "antibody_marker"
    t.string "barcode"
    t.datetime "created_at", null: false
    t.string "dimensions"
    t.string "file_name"
    t.string "file_path"
    t.integer "file_size"
    t.string "full_label_text"
    t.bigint "ims_block_id"
    t.bigint "ims_case_id", null: false
    t.string "label_image_path"
    t.integer "level_number"
    t.string "magnification"
    t.text "notes"
    t.string "qc_status", default: "pending", null: false
    t.integer "rack_position"
    t.integer "rack_row"
    t.boolean "recut_flag", default: false, null: false
    t.date "scan_date"
    t.string "scanner_name"
    t.string "slide_code", null: false
    t.integer "sort_order", default: 0, null: false
    t.string "stain_type", default: "H&E", null: false
    t.string "tags", default: [], array: true
    t.string "thumbnail_path"
    t.datetime "updated_at", null: false
    t.datetime "upload_date"
    t.string "viewer_url"
    t.string "workflow_status", default: "uploaded", null: false
    t.index ["ims_block_id"], name: "index_ims_slides_on_ims_block_id"
    t.index ["ims_case_id"], name: "index_ims_slides_on_ims_case_id"
    t.index ["qc_status"], name: "index_ims_slides_on_qc_status"
    t.index ["stain_type"], name: "index_ims_slides_on_stain_type"
    t.index ["workflow_status"], name: "index_ims_slides_on_workflow_status"
  end

  create_table "ims_staff_members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "initials"
    t.boolean "is_active", default: true, null: false
    t.string "name", null: false
    t.string "role", default: "Staff", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ims_staff_messages", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.boolean "is_read", default: false, null: false
    t.string "recipient_name", null: false
    t.string "sender_name", default: "Dr. Reynolds", null: false
    t.string "subject"
    t.datetime "updated_at", null: false
  end

  create_table "ims_sub_reports", force: :cascade do |t|
    t.text "clinical_history"
    t.datetime "created_at", null: false
    t.text "diagnosis"
    t.text "gross_description"
    t.bigint "ims_case_id", null: false
    t.text "microscopic_description"
    t.text "notes"
    t.string "pathologist"
    t.string "report_status", default: "draft", null: false
    t.string "sub_type", null: false
    t.datetime "updated_at", null: false
    t.datetime "verified_at"
    t.index ["ims_case_id"], name: "index_ims_sub_reports_on_ims_case_id"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.boolean "is_read", default: false, null: false
    t.text "message", null: false
    t.text "source"
    t.integer "source_id"
    t.text "title", null: false
    t.text "type", null: false
  end

  create_table "prep_requests", id: :serial, force: :cascade do |t|
    t.integer "block_id"
    t.integer "case_id", null: false
    t.timestamptz "completed_at"
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.integer "levels"
    t.text "marker_or_stain"
    t.text "notes"
    t.text "request_type", null: false
    t.text "requested_by"
    t.text "status", default: "pending", null: false
  end

  create_table "reason_disclaimers", id: :serial, force: :cascade do |t|
    t.text "disclaimer", null: false
    t.text "reason", null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false

    t.unique_constraint ["reason"], name: "reason_disclaimers_reason_unique"
  end

  create_table "report_shares", id: :serial, force: :cascade do |t|
    t.integer "case_id", null: false
    t.text "channel", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "message"
    t.text "recipient_email"
    t.text "recipient_name", null: false
    t.text "recipient_phone"
    t.text "recipient_type", null: false
    t.text "shared_by"
  end

  create_table "saved_contacts", id: :serial, force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "email", null: false
    t.text "institution"
    t.text "name", null: false
    t.text "specialty"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.text "key", null: false
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.text "value", null: false

    t.unique_constraint ["key"], name: "settings_key_unique"
  end

  create_table "share_comments", id: :serial, force: :cascade do |t|
    t.text "author_name", null: false
    t.text "content", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.boolean "is_read", default: false, null: false
    t.integer "share_link_id", null: false
  end

  create_table "share_links", id: :serial, force: :cascade do |t|
    t.integer "case_id", null: false
    t.jsonb "case_ids"
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "created_by", default: "Dr. Reynolds", null: false
    t.text "disclaimer"
    t.timestamptz "expires_at", null: false
    t.boolean "include_case_info", default: true, null: false
    t.boolean "include_draft_report", default: false, null: false
    t.boolean "include_gross_docs", default: true, null: false
    t.boolean "include_report", default: false, null: false
    t.boolean "include_slides", default: true, null: false
    t.boolean "is_active", default: true, null: false
    t.boolean "is_draft", default: false, null: false
    t.text "notes"
    t.text "password_hash", null: false
    t.text "password_plain"
    t.text "reason"
    t.text "recipient_email"
    t.text "recipient_name"
    t.jsonb "recipients"
    t.text "token", null: false
    t.integer "view_count", default: 0, null: false

    t.unique_constraint ["token"], name: "share_links_token_unique"
  end

  create_table "slides", id: :serial, force: :cascade do |t|
    t.text "antibody_marker"
    t.text "barcode"
    t.integer "block_id"
    t.integer "case_id", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "dimensions"
    t.text "file_name"
    t.text "file_path"
    t.integer "file_size"
    t.text "full_label_text"
    t.text "label_image_path"
    t.integer "level_number"
    t.text "magnification"
    t.text "notes"
    t.text "qc_status", default: "pending", null: false
    t.integer "rack_position"
    t.integer "rack_row"
    t.boolean "recut_flag", default: false, null: false
    t.date "scan_date"
    t.text "scanner_name"
    t.text "slide_code", null: false
    t.integer "sort_order", default: 0, null: false
    t.text "stain_type", default: "H&E", null: false
    t.text "tags", default: [], null: false, array: true
    t.text "thumbnail_path"
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.timestamptz "upload_date", default: -> { "now()" }, null: false
    t.text "viewer_url"
    t.text "workflow_status", default: "uploaded", null: false
  end

  create_table "staff_members", id: :serial, force: :cascade do |t|
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "initials"
    t.boolean "is_active", default: true, null: false
    t.text "name", null: false
    t.text "role", default: "Staff", null: false
  end

  create_table "staff_messages", id: :serial, force: :cascade do |t|
    t.text "content", null: false
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.boolean "is_read", default: false, null: false
    t.text "recipient_name", null: false
    t.text "sender_name", default: "Dr. Reynolds", null: false
    t.text "subject"
  end

  create_table "sub_reports", id: :serial, force: :cascade do |t|
    t.integer "case_id", null: false
    t.text "clinical_history"
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.text "diagnosis"
    t.text "gross_description"
    t.text "microscopic_description"
    t.text "notes"
    t.text "pathologist"
    t.text "report_status", default: "draft", null: false
    t.text "type", null: false
    t.timestamptz "updated_at", default: -> { "now()" }, null: false
    t.timestamptz "verified_at"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "blocks", "cases", name: "blocks_case_id_cases_id_fk", on_delete: :cascade
  add_foreign_key "documents", "cases", name: "documents_case_id_cases_id_fk", on_delete: :cascade
  add_foreign_key "gross_images", "cases", name: "gross_images_case_id_cases_id_fk", on_delete: :cascade
  add_foreign_key "ims_blocks", "ims_cases", on_delete: :cascade
  add_foreign_key "ims_documents", "ims_cases", on_delete: :cascade
  add_foreign_key "ims_gross_images", "ims_cases", on_delete: :cascade
  add_foreign_key "ims_prep_requests", "ims_cases"
  add_foreign_key "ims_report_shares", "ims_cases", on_delete: :cascade
  add_foreign_key "ims_share_comments", "ims_share_links", on_delete: :cascade
  add_foreign_key "ims_share_links", "ims_cases", on_delete: :cascade
  add_foreign_key "ims_slides", "ims_blocks", on_delete: :nullify
  add_foreign_key "ims_slides", "ims_cases", on_delete: :cascade
  add_foreign_key "ims_sub_reports", "ims_cases"
  add_foreign_key "prep_requests", "cases", name: "prep_requests_case_id_cases_id_fk"
  add_foreign_key "report_shares", "cases", name: "report_shares_case_id_cases_id_fk", on_delete: :cascade
  add_foreign_key "share_comments", "share_links", name: "share_comments_share_link_id_share_links_id_fk", on_delete: :cascade
  add_foreign_key "share_links", "cases", name: "share_links_case_id_cases_id_fk", on_delete: :cascade
  add_foreign_key "slides", "blocks", name: "slides_block_id_blocks_id_fk", on_delete: :nullify
  add_foreign_key "slides", "cases", name: "slides_case_id_cases_id_fk", on_delete: :cascade
  add_foreign_key "sub_reports", "cases", name: "sub_reports_case_id_cases_id_fk"
end
