require "prawn"
require "prawn/table"

module Api
  module Ims
    class ReportPdfController < ApplicationController
      def show
        kase = ImsCase.find(params[:case_id])

        pdf = Prawn::Document.new(page_size: "A4", margin: [40, 40, 40, 40])

        disclaimer = ImsSetting.get("report_pdf_disclaimer") || ""

        pdf.font_size 10

        pdf.text "PATHOLOGY REPORT", size: 18, style: :bold, align: :center
        pdf.move_down 4
        pdf.text "#{kase.accession_number}", size: 14, align: :center
        pdf.move_down 8
        pdf.stroke_horizontal_rule
        pdf.move_down 8

        patient_data = [
          ["Patient", kase.patient_name.to_s, "ID", kase.patient_identifier.to_s],
          ["Age / Gender", "#{kase.patient_age} / #{kase.patient_gender}", "Pathologist", kase.pathologist.to_s],
          ["Specimen Type", kase.specimen_type.to_s, "Organ / Site", kase.organ_site.to_s],
          ["Collection Date", kase.collection_date.to_s, "Referral Doctor", kase.referral_doctor.to_s],
        ]

        pdf.table(patient_data, cell_style: { border_width: 0.5, padding: [4, 6] }, width: pdf.bounds.width) do |t|
          t.column(0).font_style = :bold
          t.column(2).font_style = :bold
        end
        pdf.move_down 12

        [
          ["Clinical History", kase.clinical_history],
          ["Gross Description", kase.gross_description],
          ["Microscopic Description", kase.microscopic_description],
          ["Diagnosis", kase.diagnosis],
          ["Notes", kase.notes],
        ].each do |label, value|
          next if value.blank?
          pdf.text label, style: :bold
          pdf.text value.to_s
          pdf.move_down 6
        end

        pdf.move_down 8
        pdf.stroke_horizontal_rule
        pdf.move_down 6

        status_label = kase.report_status == "signed" ? "VERIFIED / SIGNED REPORT" : "DRAFT REPORT — NOT VERIFIED"
        pdf.text status_label, style: :bold, align: :center
        pdf.text "Pathologist: #{kase.pathologist}", align: :center
        pdf.text "Signed At: #{kase.signed_at&.strftime("%Y-%m-%d %H:%M") || "N/A"}", align: :center

        if disclaimer.present?
          pdf.move_down 12
          pdf.stroke_horizontal_rule
          pdf.move_down 4
          pdf.text disclaimer, size: 8, color: "888888"
        end

        send_data pdf.render,
          filename: "#{kase.accession_number}-report.pdf",
          type: "application/pdf",
          disposition: "inline"
      end

      def report_shares_index
        kase = ImsCase.find(params[:case_id])
        render json: kase.ims_report_shares.order(created_at: :desc).map { |s| serialize_share(s) }
      end

      def create_report_share
        kase = ImsCase.find(params[:case_id])
        share = kase.ims_report_shares.create!(
          recipient_type: params[:recipient_type],
          recipient_name: params[:recipient_name],
          recipient_phone: params[:recipient_phone],
          recipient_email: params[:recipient_email],
          channel: params[:channel],
          message: params[:message],
          shared_by: params[:shared_by]
        )
        render json: serialize_share(share), status: :created
      end

      def report_shares_list
        page = (params[:page] || 1).to_i
        limit = (params[:limit] || 50).to_i
        offset = (page - 1) * limit
        scope = ImsReportShare.includes(:ims_case)
        total = scope.count
        shares = scope.order(created_at: :desc).limit(limit).offset(offset)
        render json: {
          shares: shares.map { |s| serialize_share(s) },
          total: total,
          page: page,
          limit: limit
        }
      end

      private

      def serialize_share(s)
        {
          id: s.id,
          caseId: s.ims_case_id,
          recipientType: s.recipient_type,
          recipientName: s.recipient_name,
          recipientPhone: s.recipient_phone,
          recipientEmail: s.recipient_email,
          channel: s.channel,
          message: s.message,
          sharedBy: s.shared_by,
          createdAt: s.created_at,
          accessionNumber: s.ims_case&.accession_number,
        }
      end
    end
  end
end