namespace :ims do
  desc "Export current IMS data as a SQL seed file for import into the LIS database"
  task export_for_lis: :environment do
    output_path = ENV.fetch("OUTPUT", Rails.root.join("tmp", "ims_export.sql").to_s)
    FileUtils.mkdir_p(File.dirname(output_path))

    conn = ActiveRecord::Base.connection

    def quoted_value(val)
      return "NULL" if val.nil?
      case val
      when TrueClass  then "true"
      when FalseClass then "false"
      when Integer, Float then val.to_s
      else
        "'#{val.to_s.gsub("'", "''")}'"
      end
    end

    def export_table(conn, table, file)
      rows = conn.exec_query("SELECT * FROM #{table} ORDER BY id").to_a
      return if rows.empty?

      file.puts "-- #{table} (#{rows.size} rows)"
      columns = rows.first.keys.join(", ")

      rows.each do |row|
        values = row.values.map { |v| quoted_value(v) }.join(", ")
        file.puts "INSERT INTO #{table} (#{columns}) VALUES (#{values}) ON CONFLICT DO NOTHING;"
      end
      file.puts ""
    end

    def export_table_no_id(conn, table, file)
      rows = conn.exec_query("SELECT * FROM #{table}").to_a
      return if rows.empty?

      file.puts "-- #{table} (#{rows.size} rows)"
      columns = rows.first.keys.join(", ")

      rows.each do |row|
        values = row.values.map { |v| quoted_value(v) }.join(", ")
        file.puts "INSERT INTO #{table} (#{columns}) VALUES (#{values}) ON CONFLICT DO NOTHING;"
      end
      file.puts ""
    end

    File.open(output_path, "w") do |f|
      f.puts "-- IMS Export for LIS import"
      f.puts "-- Generated: #{Time.current}"
      f.puts "-- Run inside the LIS Rails project after running IMS migrations:"
      f.puts "--   psql $DATABASE_URL < ims_export.sql"
      f.puts ""

      f.puts "BEGIN;"
      f.puts ""

      tables_with_id = %w[
        ims_cases
        ims_blocks
        ims_slides
        ims_gross_images
        ims_documents
        ims_prep_requests
        ims_sub_reports
        ims_notifications
        ims_staff_members
        ims_staff_messages
        ims_saved_contacts
        ims_share_links
        ims_report_shares
        ims_share_comments
      ]

      tables_without_id = %w[
        ims_reason_disclaimers
        ims_settings
        module_licenses
      ]

      tables_with_id.each    { |t| export_table(conn, t, f) }
      tables_without_id.each { |t| export_table_no_id(conn, t, f) }

      f.puts "-- Reset primary key sequences"
      tables_with_id.each do |table|
        f.puts "SELECT setval('#{table}_id_seq', COALESCE((SELECT MAX(id) FROM #{table}), 1));"
      end
      f.puts ""
      f.puts "COMMIT;"
    end

    puts "IMS export written to: #{output_path}"
    puts ""
    puts "Row counts:"
    (tables_with_id + tables_without_id).each do |table|
      count = conn.exec_query("SELECT COUNT(*) FROM #{table}").rows.first.first rescue 0
      puts "  #{table}: #{count}"
    end
  end
end
