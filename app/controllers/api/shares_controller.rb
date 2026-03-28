require "bcrypt"

module Api
  module Ims
    class SharesController < ApplicationController
      CURRENT_USER = "Dr. Reynolds"

      def index
        rows = ImsShareLink.order(created_at: :desc).includes(:ims_case, :ims_share_comments)
        render json: rows.map { |s| serialize_share(s) }
      end

      def create
        token = SecureRandom.urlsafe_base64(24)
        password = params[:password] || SecureRandom.hex(4)
        password_hash = BCrypt::Password.create(password)
        expires_hours = (params[:expires_hours] || 72).to_i

        kase_id = params[:case_id].to_i
        share = ImsShareLink.new(
          ims_case_id: kase_id > 0 ? kase_id : ImsCase.first&.id || 1,
          case_ids: params[:case_ids],
          token: token,
          password_hash: password_hash.to_s,
          expires_at: expires_hours.hours.from_now,
          created_by: params[:created_by] || CURRENT_USER,
          recipient_name: params[:recipient_name],
          recipient_email: params[:recipient_email],
          recipients: params[:recipients],
          include_slides: params.fetch(:include_slides, true),
          include_gross_docs: params.fetch(:include_gross_docs, true),
          include_case_info: params.fetch(:include_case_info, true),
          include_report: params.fetch(:include_report, false),
          include_draft_report: params.fetch(:include_draft_report, false),
          reason: params[:reason],
          disclaimer: params[:disclaimer],
          notes: params[:notes],
          is_draft: params.fetch(:is_draft, false),
          is_active: true,
          view_count: 0
        )

        if share.save
          render json: serialize_share(share).merge(passwordPlain: password), status: :created
        else
          render json: { error: share.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      def update
        share = ImsShareLink.find(params[:id])
        updates = {}
        updates[:recipient_name] = params[:recipient_name] if params[:recipient_name]
        updates[:recipient_email] = params[:recipient_email] if params[:recipient_email]
        updates[:recipients] = params[:recipients] if params[:recipients]
        updates[:include_slides] = params[:include_slides] unless params[:include_slides].nil?
        updates[:include_gross_docs] = params[:include_gross_docs] unless params[:include_gross_docs].nil?
        updates[:include_case_info] = params[:include_case_info] unless params[:include_case_info].nil?
        updates[:include_report] = params[:include_report] unless params[:include_report].nil?
        updates[:include_draft_report] = params[:include_draft_report] unless params[:include_draft_report].nil?
        updates[:reason] = params[:reason] if params.key?(:reason)
        updates[:disclaimer] = params[:disclaimer] if params.key?(:disclaimer)
        updates[:notes] = params[:notes] if params.key?(:notes)
        updates[:is_draft] = params[:is_draft] unless params[:is_draft].nil?
        updates[:is_active] = params[:is_active] unless params[:is_active].nil?
        updates[:case_ids] = params[:case_ids] if params[:case_ids]

        if share.update(updates)
          render json: serialize_share(share)
        else
          render json: { error: share.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      def validate
        share = ImsShareLink.find_by!(token: params[:token])
        password = params[:password].to_s

        begin
          stored = BCrypt::Password.new(share.password_hash)
          password_valid = stored == password
        rescue BCrypt::Errors::InvalidHash
          password_valid = false
        end

        unless password_valid
          return render json: { error: "Invalid password" }, status: :unauthorized
        end
        if share.expires_at < Time.current
          return render json: { error: "Share link has expired" }, status: :gone
        end
        unless share.is_active
          return render json: { error: "Share link has been revoked" }, status: :gone
        end

        share.increment!(:view_count)
        render json: { valid: true, shareLink: serialize_share(share) }
      end

      def shared_case
        share = find_and_authorize_share!(params[:token], params[:password])
        return unless share

        case_ids = share.case_ids.presence || [share.ims_case_id]
        cases = ImsCase.where(id: case_ids).includes({ ims_blocks: :ims_slides }, :ims_gross_images, :ims_documents)

        result = cases.map { |kase| serialize_case_for_share(kase, share) }

        render json: result.length == 1 ? result.first : result
      end

      def comments
        share = find_and_authorize_share!(params[:token], params[:password])
        return unless share

        render json: share.ims_share_comments.order(created_at: :asc).map { |c| serialize_comment(c) }
      end

      def create_comment
        share = find_and_authorize_share!(params[:token], params[:password])
        return unless share

        comment = share.ims_share_comments.create!(
          author_name: params[:author_name] || "Consultant",
          content: params[:content]
        )
        render json: serialize_comment(comment), status: :created
      end

      def reason_disclaimers
        rows = ImsReasonDisclaimer.all
        map = rows.each_with_object({}) { |r, h| h[r.reason] = r.disclaimer }
        render json: map
      end

      def update_reason_disclaimer
        reason = params[:reason]
        disclaimer = params[:disclaimer]
        return render json: { error: "disclaimer is required" }, status: :bad_request if disclaimer.blank?

        rd = ImsReasonDisclaimer.find_or_initialize_by(reason: reason)
        rd.disclaimer = disclaimer
        rd.save!
        render json: { success: true }
      end

      def contacts
        render json: ImsSavedContact.order(:name)
      end

      def create_contact
        contact = ImsSavedContact.create!(
          name: params[:name],
          email: params[:email],
          institution: params[:institution],
          specialty: params[:specialty]
        )
        render json: contact, status: :created
      end

      def destroy_contact
        ImsSavedContact.find(params[:id]).destroy
        render json: { success: true }
      end

      def queue_shared
        links = ImsShareLink.where(is_active: true).where("expires_at > ?", Time.current).order(created_at: :desc)
        case_ids = links.flat_map { |l| l.case_ids.presence || [l.ims_case_id] }.uniq.compact
        cases = ImsCase.where(id: case_ids)
        cases_with_shares = cases.map { |c|
          c_hash = serialize_case_summary(c)
          c_hash[:shareLinks] = links.select { |l| (l.case_ids.presence || [l.ims_case_id]).include?(c.id) }.map { |l| serialize_share(l) }
          c_hash
        }
        render json: { cases: cases_with_shares, shareLinks: links.map { |l| serialize_share(l) } }
      end

      private

      def find_and_authorize_share!(token, password)
        share = ImsShareLink.find_by!(token: token)

        begin
          stored = BCrypt::Password.new(share.password_hash)
          password_valid = stored == password.to_s
        rescue BCrypt::Errors::InvalidHash
          password_valid = false
        end

        unless password_valid
          render json: { error: "Invalid password" }, status: :unauthorized
          return nil
        end

        if share.expires_at < Time.current
          render json: { error: "Share link has expired" }, status: :gone
          return nil
        end

        unless share.is_active
          render json: { error: "Share link has been revoked" }, status: :gone
          return nil
        end

        share
      end

      def serialize_share(share)
        {
          id: share.id,
          caseId: share.ims_case_id,
          caseIds: share.case_ids,
          token: share.token,
          expiresAt: share.expires_at,
          createdBy: share.created_by,
          recipientName: share.recipient_name,
          recipientEmail: share.recipient_email,
          recipients: share.recipients,
          includeSlides: share.include_slides,
          includeGrossDocs: share.include_gross_docs,
          includeCaseInfo: share.include_case_info,
          includeReport: share.include_report,
          includeDraftReport: share.include_draft_report,
          reason: share.reason,
          disclaimer: share.disclaimer,
          notes: share.notes,
          isDraft: share.is_draft,
          isActive: share.is_active,
          viewCount: share.view_count,
          createdAt: share.created_at,
          accessionNumber: share.ims_case&.accession_number,
          organSite: share.ims_case&.organ_site,
          specimenType: share.ims_case&.specimen_type,
        }
      end

      def serialize_comment(comment)
        {
          id: comment.id,
          shareLinkId: comment.ims_share_link_id,
          authorName: comment.author_name,
          content: comment.content,
          isRead: comment.is_read,
          createdAt: comment.created_at,
        }
      end

      def serialize_case_summary(kase)
        {
          id: kase.id,
          accessionNumber: kase.accession_number,
          patientIdentifier: kase.patient_identifier,
          patientName: kase.patient_name,
          specimenType: kase.specimen_type,
          organSite: kase.organ_site,
          status: kase.status,
          reportStatus: kase.report_status,
        }
      end

      def serialize_case_for_share(kase, share)
        data = {
          id: kase.id,
          accessionNumber: kase.accession_number,
          patientIdentifier: kase.patient_identifier,
          patientName: kase.patient_name,
          patientAge: kase.patient_age,
          patientGender: kase.patient_gender,
          specimenType: kase.specimen_type,
          organSite: kase.organ_site,
          pathologist: kase.pathologist,
          status: kase.status,
          reportStatus: kase.report_status,
          signedAt: kase.signed_at,
          diagnosis: kase.diagnosis,
          diagnosisCategory: kase.diagnosis_category,
          clinicalHistory: kase.clinical_history,
          grossDescription: kase.gross_description,
          microscopicDescription: kase.microscopic_description,
          notes: kase.notes,
        }

        if share.include_slides
          data[:slides] = kase.ims_slides.order(:sort_order).map { |s|
            { id: s.id, slideCode: s.slide_code, stainType: s.stain_type, filePath: s.file_path,
              qcStatus: s.qc_status, viewerUrl: s.viewer_url, fileName: s.file_name }
          }
        end

        if share.include_gross_docs
          data[:grossImages] = kase.ims_gross_images.order(:sort_order).map { |img|
            { id: img.id, fileName: img.file_name, filePath: img.file_path, mimeType: img.mime_type }
          }
          data[:documents] = kase.ims_documents.order(:created_at).map { |doc|
            { id: doc.id, fileName: doc.file_name, filePath: doc.file_path, fileType: doc.file_type }
          }
        end

        data
      end
    end
  end
end