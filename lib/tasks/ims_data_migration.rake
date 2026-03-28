namespace :ims do
  desc "Migrate IMS data directly from source PostgreSQL tables (same heliumdb) to ims_* Rails tables"
  task migrate_from_node: :environment do
    require "bcrypt"

    conn = ActiveRecord::Base.connection
    puts "Migrating IMS data via direct DB-to-DB copy (source: heliumdb) ..."
    puts "Source DB: #{ActiveRecord::Base.connection_db_config.database}"

    def exec_query(conn, sql)
      conn.exec_query(sql).to_a
    rescue ActiveRecord::StatementInvalid => e
      puts "  Warning: #{e.message}"
      []
    end

    step = 0

    step += 1
    puts "\n[#{step}] Migrating Settings..."
    total_settings = 0
    rows = exec_query(conn, "SELECT key, value FROM settings ORDER BY id")
    rows.each do |r|
      next if r["key"].blank?
      ImsSetting.find_or_create_by(key: r["key"]) { |s| s.value = r["value"].to_s }
      print "."
      total_settings += 1
    end
    puts " #{total_settings} settings migrated"

    step += 1
    puts "\n[#{step}] Migrating Cases..."
    total_cases = 0
    rows = exec_query(conn, "SELECT * FROM cases ORDER BY id")
    rows.each do |c|
      next if ImsCase.exists?(id: c["id"]) || ImsCase.exists?(accession_number: c["accession_number"])
      ImsCase.create!(
        id: c["id"],
        accession_number: c["accession_number"],
        patient_identifier: c["patient_identifier"],
        patient_name: c["patient_name"],
        patient_age: c["patient_age"],
        patient_gender: c["patient_gender"],
        specimen_type: c["specimen_type"],
        organ_site: c["organ_site"],
        collection_date: c["collection_date"],
        uploaded_date: c["uploaded_date"],
        pathologist: c["pathologist"],
        status: c["status"] || "active",
        specimen_origin: c["specimen_origin"],
        specimen_size: c["specimen_size"],
        referral_doctor: c["referral_doctor"],
        referral_clinic: c["referral_clinic"],
        clinical_history: c["clinical_history"],
        gross_description: c["gross_description"],
        microscopic_description: c["microscopic_description"],
        diagnosis: c["diagnosis"],
        diagnosis_category: c["diagnosis_category"],
        report_status: c["report_status"] || "draft",
        notes: c["notes"],
        is_volunteer: c["is_volunteer"] || false,
        signed_at: c["signed_at"],
        archive_read_at: c["archive_read_at"],
        corrected_at: c["corrected_at"],
        created_at: c["created_at"],
        updated_at: c["updated_at"]
      )
      print "."
      total_cases += 1
    end
    puts " #{total_cases} cases migrated"

    step += 1
    puts "\n[#{step}] Migrating Blocks..."
    total_blocks = 0
    rows = exec_query(conn, "SELECT * FROM blocks ORDER BY id")
    rows.each do |b|
      next if ImsBlock.exists?(id: b["id"])
      next unless ImsCase.exists?(b["case_id"])
      ImsBlock.create!(
        id: b["id"],
        ims_case_id: b["case_id"],
        block_code: b["block_code"],
        specimen_part: b["specimen_part"],
        notes: b["notes"],
        created_at: b["created_at"],
        updated_at: b["updated_at"]
      )
      print "."
      total_blocks += 1
    end
    puts " #{total_blocks} blocks migrated"

    step += 1
    puts "\n[#{step}] Migrating Slides (metadata only - original files at existing file_path)..."
    total_slides = 0
    rows = exec_query(conn, "SELECT * FROM slides ORDER BY id")
    rows.each do |s|
      next if ImsSlide.exists?(id: s["id"])
      next unless ImsCase.exists?(s["case_id"])
      ImsSlide.create!(
        id: s["id"],
        ims_case_id: s["case_id"],
        ims_block_id: s["block_id"],
        slide_code: s["slide_code"],
        full_label_text: s["full_label_text"],
        stain_type: s["stain_type"] || "H&E",
        antibody_marker: s["antibody_marker"],
        level_number: s["level_number"],
        recut_flag: s["recut_flag"] || false,
        scanner_name: s["scanner_name"],
        scan_date: s["scan_date"],
        upload_date: s["upload_date"],
        file_name: s["file_name"],
        file_path: s["file_path"],
        thumbnail_path: s["thumbnail_path"],
        label_image_path: s["label_image_path"],
        barcode: s["barcode"],
        magnification: s["magnification"],
        dimensions: s["dimensions"],
        file_size: s["file_size"],
        qc_status: s["qc_status"] || "pending",
        workflow_status: s["workflow_status"] || "uploaded",
        viewer_url: s["viewer_url"],
        rack_row: s["rack_row"],
        rack_position: s["rack_position"],
        sort_order: s["sort_order"] || 0,
        tags: s["tags"] || [],
        notes: s["notes"],
        created_at: s["created_at"],
        updated_at: s["updated_at"]
      )
      print "."
      total_slides += 1
    end
    puts " #{total_slides} slides migrated"

    step += 1
    puts "\n[#{step}] Migrating Gross Images (metadata only - original files at existing file_path)..."
    total_gross = 0
    rows = exec_query(conn, "SELECT * FROM gross_images ORDER BY id")
    rows.each do |g|
      next if ImsGrossImage.exists?(id: g["id"])
      next unless ImsCase.exists?(g["case_id"])
      ImsGrossImage.create!(
        id: g["id"],
        ims_case_id: g["case_id"],
        block_id: g["block_id"],
        file_name: g["file_name"],
        file_path: g["file_path"],
        thumbnail_path: g["thumbnail_path"],
        file_size: g["file_size"].to_i,
        mime_type: g["mime_type"],
        caption: g["caption"],
        sort_order: g["sort_order"].to_i,
        upload_date: g["upload_date"],
        created_at: g["created_at"],
        updated_at: g["updated_at"]
      )
      print "."
      total_gross += 1
    end
    puts " #{total_gross} gross images migrated"

    step += 1
    puts "\n[#{step}] Migrating Documents (metadata only - original files at existing file_path)..."
    total_docs = 0
    rows = exec_query(conn, "SELECT * FROM documents ORDER BY id")
    rows.each do |d|
      next if ImsDocument.exists?(id: d["id"])
      next unless ImsCase.exists?(d["case_id"])
      ImsDocument.create!(
        id: d["id"],
        ims_case_id: d["case_id"],
        file_name: d["file_name"],
        file_path: d["file_path"],
        file_size: d["file_size"].to_i,
        file_type: d["file_type"],
        mime_type: d["mime_type"],
        category: d["category"] || "general",
        description: d["description"],
        upload_date: d["upload_date"],
        created_at: d["created_at"],
        updated_at: d["updated_at"]
      )
      print "."
      total_docs += 1
    end
    puts " #{total_docs} documents migrated"

    step += 1
    puts "\n[#{step}] Migrating Prep Requests..."
    total_prep = 0
    rows = exec_query(conn, "SELECT * FROM prep_requests ORDER BY id")
    rows.each do |r|
      next if ImsPrepRequest.exists?(id: r["id"])
      next unless ImsCase.exists?(r["case_id"])
      ImsPrepRequest.create!(
        id: r["id"],
        ims_case_id: r["case_id"],
        block_id: r["block_id"],
        request_type: r["request_type"],
        marker_or_stain: r["marker_or_stain"],
        levels: r["levels"],
        notes: r["notes"],
        status: r["status"] || "pending",
        requested_by: r["requested_by"],
        completed_at: r["completed_at"],
        created_at: r["created_at"]
      )
      print "."
      total_prep += 1
    end
    puts " #{total_prep} prep requests migrated"

    step += 1
    puts "\n[#{step}] Migrating Sub-Reports..."
    total_sub = 0
    rows = exec_query(conn, "SELECT * FROM sub_reports ORDER BY id")
    rows.each do |r|
      next if ImsSubReport.exists?(id: r["id"])
      next unless ImsCase.exists?(r["case_id"])
      ImsSubReport.create!(
        id: r["id"],
        ims_case_id: r["case_id"],
        sub_type: r["type"] || "addendum",
        pathologist: r["pathologist"],
        clinical_history: r["clinical_history"],
        gross_description: r["gross_description"],
        microscopic_description: r["microscopic_description"],
        diagnosis: r["diagnosis"],
        notes: r["notes"],
        report_status: r["report_status"] || "draft",
        verified_at: r["verified_at"],
        created_at: r["created_at"],
        updated_at: r["updated_at"]
      )
      print "."
      total_sub += 1
    end
    puts " #{total_sub} sub-reports migrated"

    step += 1
    puts "\n[#{step}] Migrating Notifications..."
    total_notifs = 0
    rows = exec_query(conn, "SELECT * FROM notifications ORDER BY id")
    rows.each do |n|
      next if ImsNotification.exists?(id: n["id"])
      ImsNotification.create!(
        id: n["id"],
        ntype: n["type"] || "info",
        title: n["title"],
        message: n["message"],
        source: n["source"],
        source_id: n["source_id"],
        is_read: n["is_read"] || false,
        created_at: n["created_at"]
      )
      print "."
      total_notifs += 1
    end
    puts " #{total_notifs} notifications migrated"

    step += 1
    puts "\n[#{step}] Migrating Staff Messages..."
    total_msgs = 0
    rows = exec_query(conn, "SELECT * FROM staff_messages ORDER BY id")
    rows.each do |m|
      next if ImsStaffMessage.exists?(id: m["id"])
      ImsStaffMessage.create!(
        id: m["id"],
        sender_name: m["sender_name"],
        recipient_name: m["recipient_name"],
        subject: m["subject"],
        content: m["content"],
        is_read: m["is_read"] || false,
        created_at: m["created_at"]
      )
      print "."
      total_msgs += 1
    end
    puts " #{total_msgs} staff messages migrated"

    step += 1
    puts "\n[#{step}] Migrating Staff Members..."
    total_staff = 0
    rows = exec_query(conn, "SELECT * FROM staff_members ORDER BY id")
    rows.each do |m|
      next if ImsStaffMember.exists?(id: m["id"])
      ImsStaffMember.create!(
        id: m["id"],
        name: m["name"],
        role: m["role"] || "Staff",
        initials: m["initials"],
        is_active: m["is_active"] != false,
        created_at: m["created_at"]
      )
      print "."
      total_staff += 1
    end
    puts " #{total_staff} staff members migrated"

    step += 1
    puts "\n[#{step}] Migrating Contacts..."
    total_contacts = 0
    rows = exec_query(conn, "SELECT * FROM saved_contacts ORDER BY id")
    rows.each do |c|
      next if ImsSavedContact.exists?(email: c["email"])
      ImsSavedContact.create!(
        id: c["id"],
        name: c["name"],
        email: c["email"],
        institution: c["institution"],
        specialty: c["specialty"],
        created_at: c["created_at"]
      )
      print "."
      total_contacts += 1
    end
    puts " #{total_contacts} contacts migrated"

    step += 1
    puts "\n[#{step}] Migrating Share Links (passwords preserved via BCrypt re-hash from plain text)..."
    total_shares = 0
    rows = exec_query(conn, "SELECT * FROM share_links ORDER BY id")
    rows.each do |s|
      next if ImsShareLink.exists?(token: s["token"])
      next unless ImsCase.exists?(s["case_id"])
      plain = s["password_plain"].to_s.strip
      new_hash = if plain.present?
        BCrypt::Password.create(plain).to_s
      else
        BCrypt::Password.create(SecureRandom.hex(8)).to_s
      end
      ImsShareLink.create!(
        ims_case_id: s["case_id"],
        case_ids: s["case_ids"],
        token: s["token"],
        password_hash: new_hash,
        expires_at: s["expires_at"] || 30.days.from_now,
        created_by: s["created_by"],
        recipient_name: s["recipient_name"],
        recipient_email: s["recipient_email"],
        recipients: s["recipients"],
        include_slides: s["include_slides"] != false,
        include_gross_docs: s["include_gross_docs"] != false,
        include_case_info: s["include_case_info"] != false,
        include_report: s["include_report"] || false,
        include_draft_report: s["include_draft_report"] || false,
        reason: s["reason"],
        disclaimer: s["disclaimer"],
        notes: s["notes"],
        is_draft: s["is_draft"] || false,
        is_active: s["is_active"] != false,
        view_count: s["view_count"] || 0
      )
      print "."
      total_shares += 1
    end
    puts " #{total_shares} share links migrated"

    step += 1
    puts "\n[#{step}] Migrating Report Shares..."
    total_report_shares = 0
    rows = exec_query(conn, "SELECT * FROM report_shares ORDER BY id")
    rows.each do |rs|
      next if ImsReportShare.exists?(id: rs["id"])
      next unless ImsCase.exists?(rs["case_id"])
      ImsReportShare.create!(
        id: rs["id"],
        ims_case_id: rs["case_id"],
        recipient_type: rs["recipient_type"] || "external",
        recipient_name: rs["recipient_name"] || "Unknown",
        recipient_phone: rs["recipient_phone"],
        recipient_email: rs["recipient_email"],
        channel: rs["channel"] || "email",
        message: rs["message"],
        shared_by: rs["shared_by"],
        created_at: rs["created_at"]
      )
      print "."
      total_report_shares += 1
    end
    puts " #{total_report_shares} report shares migrated"

    step += 1
    puts "\n[#{step}] Migrating Reason Disclaimers..."
    total_rds = 0
    rows = exec_query(conn, "SELECT * FROM reason_disclaimers ORDER BY id")
    rows.each do |rd|
      next if ImsReasonDisclaimer.exists?(reason: rd["reason"])
      ImsReasonDisclaimer.create!(
        reason: rd["reason"],
        disclaimer: rd["disclaimer"]
      )
      print "."
      total_rds += 1
    end
    puts " #{total_rds} reason disclaimers migrated"

    puts "\nResetting PK sequences..."
    %w[ims_cases ims_blocks ims_slides ims_gross_images ims_documents ims_prep_requests
       ims_sub_reports ims_notifications ims_staff_members ims_staff_messages ims_saved_contacts
       ims_share_links ims_report_shares ims_reason_disclaimers ims_settings].each do |table|
      conn.reset_pk_sequence!(table)
    end
    puts "Sequences reset."

    puts "\nMigration complete! Summary:"
    puts "  Cases: #{ImsCase.count}"
    puts "  Blocks: #{ImsBlock.count}"
    puts "  Slides: #{ImsSlide.count}"
    puts "  Gross Images: #{ImsGrossImage.count}"
    puts "  Documents: #{ImsDocument.count}"
    puts "  Prep Requests: #{ImsPrepRequest.count}"
    puts "  Sub-Reports: #{ImsSubReport.count}"
    puts "  Notifications: #{ImsNotification.count}"
    puts "  Staff Members: #{ImsStaffMember.count}"
    puts "  Staff Messages: #{ImsStaffMessage.count}"
    puts "  Contacts: #{ImsSavedContact.count}"
    puts "  Share Links: #{ImsShareLink.count}"
    puts "  Report Shares: #{ImsReportShare.count}"
    puts "  Reason Disclaimers: #{ImsReasonDisclaimer.count}"
    puts "  Settings: #{ImsSetting.count}"
  end
end
