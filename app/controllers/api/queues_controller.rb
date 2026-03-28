module Api
  module Ims
    class QueuesController < ApplicationController
      CASE_COLS = [
        :id, :accession_number, :patient_identifier, :patient_name, :patient_age, :patient_gender,
        :specimen_type, :organ_site, :specimen_origin, :specimen_size, :referral_doctor, :referral_clinic,
        :collection_date, :uploaded_date, :pathologist, :status, :report_status, :is_volunteer,
        :signed_at, :notes, :created_at, :updated_at
      ]

      def volunteer
        cases = ImsCase.where(is_volunteer: true).order(:created_at)
        render json: { cases: cases.map { |c| serialize_case(c) } }
      end

      def archive
        search = params[:search]
        scope = ImsCase.where(report_status: "signed")
        if search.present?
          q = "%#{search}%"
          scope = scope.where("accession_number ILIKE :q OR patient_name ILIKE :q OR patient_identifier ILIKE :q", q: q)
        end
        cases = scope.order(signed_at: :desc)
        render json: { cases: cases.map { |c| serialize_case(c) } }
      end

      private

      def serialize_case(c)
        {
          id: c.id,
          accessionNumber: c.accession_number,
          patientIdentifier: c.patient_identifier,
          patientName: c.patient_name,
          patientAge: c.patient_age,
          patientGender: c.patient_gender,
          specimenType: c.specimen_type,
          organSite: c.organ_site,
          specimenOrigin: c.specimen_origin,
          specimenSize: c.specimen_size,
          referralDoctor: c.referral_doctor,
          referralClinic: c.referral_clinic,
          collectionDate: c.collection_date,
          uploadedDate: c.uploaded_date,
          pathologist: c.pathologist,
          status: c.status,
          reportStatus: c.report_status,
          isVolunteer: c.is_volunteer,
          signedAt: c.signed_at,
          notes: c.notes,
          createdAt: c.created_at,
          updatedAt: c.updated_at,
          slideCount: c.ims_slides.count,
          blockCount: c.ims_blocks.count,
          pendingRequests: c.ims_prep_requests.where(status: %w[pending in_progress]).count,
          doneRequests: c.ims_prep_requests.where(status: "done").count,
        }
      end
    end
  end
end